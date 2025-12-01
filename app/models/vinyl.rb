class Vinyl < ApplicationRecord
  has_many :vinyls_genres, :vinyl_songs, :artists_vinyls, :whishlists, :collections
end
