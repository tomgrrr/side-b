class UsersController < ApplicationController

  def collection
    @match = Match.new()
    @collections = current_user.matches.where(category: "collection")

    @matches_with_playlists = current_user.matches.where.not(playlist_id: nil)

    playlist_ids = @matches_with_playlists.pluck(:playlist_id).uniq
    @playlists = Playlist.all.order(created_at: :desc)
    @playlist_vinyl_counts = current_user.matches
    .where(category: "collection")
    .where.not(playlist_id: nil)
    .group(:playlist_id)
    .count

  end

  def wishlist
    @wishlists = Match.where(category: "wishlist")
    @match = Match.new()
  end

end
