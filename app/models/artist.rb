class Artist < ApplicationRecord
  has_many :artists_vinyls
  has_many :artist_genres
end
