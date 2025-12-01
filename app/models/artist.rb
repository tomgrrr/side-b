class Artist < ApplicationRecord
  has_many :artists_vinyls, :artist_genres
end
