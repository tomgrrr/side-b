class VinylsController < ApplicationController


  def show
  @vinyl = Vinyl.find(params[:id])

  @in_collection = current_user.matches.exists?(vinyl: @vinyl, category: "collection")
  @in_wishlist = current_user.matches.exists?(vinyl: @vinyl, category: "wishlist")

  @collection_match = current_user.matches.find_by(vinyl: @vinyl, category: "collection")
  @wishlist_match = current_user.matches.find_by(vinyl: @vinyl, category: "wishlist")

  artist_name = @vinyl.artists.first&.name
  @youtube_videos = YoutubeService.search_album(artist_name, @vinyl.name) if artist_name

end

  def index
    @vinyl = Vinyl.all
  end
end
