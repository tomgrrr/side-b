class Genre < ApplicationRecord
  has_many :vinyls_genres
  has_many :artist_genres

  has_neighbors :embedding
  after_create :set_embedding

  def self.clean(genres)
    genres.flat_map { |g| JSON.parse(g.name) }.uniq
  end

  private


  def set_embedding
    embedding = RubyLLM.embed("Genre: #{name}")
    update(embedding: embedding.vectors)
  end
end
