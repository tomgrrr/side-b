class Genre < ApplicationRecord
  has_many :vinyls_genres, :artist_genres
end
