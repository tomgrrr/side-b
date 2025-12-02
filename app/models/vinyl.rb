class Vinyl < ApplicationRecord
  has_many :vinyls_genres
  has_many :vinyl_songs
  has_many :artists_vinyls
  has_many :matches
end
