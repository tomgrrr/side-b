class Vinyl < ApplicationRecord
  has_many :vinyls_genres
  has_many :vinyl_songs
  has_many :artists_vinyls
  has_many :artists, through: :artists_vinyls
  has_many :matches
  has_many :genres, through: :vinyls_genres

  has_neighbors :embedding
  after_create :set_embedding

  def parsed_songs
    if songs.blank?
      return []
    else
      songs.split("|").map(&:strip)
    end
  end

  private

  def set_embedding
    embedding = RubyLLM.embed("Artist: #{name}. Genres: #{genres}. Vinyls: #{name}")
    update(embedding: embedding.vectors)
  end
end
