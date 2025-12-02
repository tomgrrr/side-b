class UsersController < ApplicationController

  def collection
    @collections = Match.where(type: "collection")
  end

  def wishlist
    @wishlists = Match.where(type: "wishlist")
  end
  
end
