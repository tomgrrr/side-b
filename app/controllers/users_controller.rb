class UsersController < ApplicationController

  def collection
    @collections = current_user.matches.where(category: "collection")
    @playlists = current_user.matches.where.not(playlist_id: nil)

  end

  def wishlist
    @wishlists = Match.where(collection: "wishlist")
  end

end
