class Artist < ApplicationRecord
  has_many :artists_vinyls
  has_many :artist_genres
  has_many :genres, through: :artist_genres
  has_many :vinyls, through: :artists_vinyls

  has_neighbors :embedding
  after_create :set_embedding

  private

  def set_embedding
    embedding = RubyLLM.embed("Artist: #{name}. Genres: #{genres}. Vinyls: #{vinyls}")
    update(embedding: embedding.vectors)
  end
end
