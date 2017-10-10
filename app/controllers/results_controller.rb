class ResultsController < ApplicationController
 def index
 	query = params[:q]
 	@youtube_search = YoutubeSearch.new
 	@results = @youtube_search.search query
 	@videos = @youtube_search.videos
 end
end
