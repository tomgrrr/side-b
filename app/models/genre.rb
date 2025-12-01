class Genre < ApplicationRecord
  has_many :vinyls_genres
  has_many :artist_genres
end
