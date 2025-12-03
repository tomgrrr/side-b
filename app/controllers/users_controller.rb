class UsersController < ApplicationController

  def collection
    @collections = current_user.matches.where(category: "collection")
  end

  def wishlist
    @wishlists = Match.where(collection: "wishlist")
  end

end
