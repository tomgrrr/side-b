class Vinyl < ApplicationRecord
  has_many :vinyls_genres
  has_many :vinyl_songs
  has_many :artists_vinyls
  has_many :artists, through: :artists_vinyls
  has_many :matches

  def parsed_songs
    return [] if songs.blank?
    JSON.parse(songs)
  rescue JSON::ParserError
    []
  end
end
