require 'google/api_client'

class YoutubeSearch
  # Please use your own API key and enable the Youtube API for it
  # This default key is provided for your convenience but it will be invalid soon
  # On Heroku, you can set `heroku config:set GOOGLE_API_KEY=your-key-value
  # On localhost, you can set the GOOGLE_API_KEY ENV variable or use the dotenv gem
  DEVELOPER_KEY = ENV['GOOGLE_API_KEY'] || 'AIzaSyAiYpoyH1ytduemNagGHikWWGTVsO-Nc7Y'
  YOUTUBE_API_SERVICE_NAME = 'youtube'
  YOUTUBE_API_VERSION = 'v3'

  attr_reader :videos, :playlists, :channels

  def initialize
    get_service
  end

  def get_service
    @client = Google::APIClient.new(
      :key => DEVELOPER_KEY,
      :authorization => nil,
      :application_name => $PROGRAM_NAME,
      :application_version => '1.0.0'
    )
    @youtube = @client.discovered_api(YOUTUBE_API_SERVICE_NAME, YOUTUBE_API_VERSION)

    return @client, @youtube
  end


  def search(query)
    @search = {}
    return @search[query] if @search[query]

    search_response = @client.execute!(
      :api_method => @youtube.search.list,
      :parameters => {
        :part => 'snippet',
        :q => query,
        :maxResults => max_result,
      }
    )

    
    @search[query] = search_response.data.items
    @videos = []
    @channels = []
    @playlists = []

    @search[query].each do |search_result|
       case search_result.id.kind
        when 'youtube#video'
          video = Video.new
          video.raw_result = search_result
         @videos << video
        when 'youtube#channel'
          @channels << search_result # "#{search_result.snippet.title} (#{search_result.id.channelId})"
        when 'youtube#playlist'
          @playlists << search_result # "#{search_result.snippet.title} (#{search_result.id.playlistId})"
      end
    end

    @search[query]
  end

  def max_result
    25
  end

end
