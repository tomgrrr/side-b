class Vinyl < ApplicationRecord
  has_many :vinyls_genres
  has_many :vinyl_songs
  has_many :artists_vinyls
  has_many :artists, through: :artists_vinyls
  has_many :matches
  has_many :genres, through: :vinyls_genres
  has_many :vinyl_recommandations

  has_neighbors :embedding
  after_create :set_embedding

  def parsed_songs
    if songs.blank?
      return []
    else
      songs.split("|").map(&:strip)
    end
  end

  def parsed_genres
    genres.flat_map { |g| JSON.parse(g.name) rescue [g.name] }.uniq
  end


  private

  def set_embedding
    embedding = RubyLLM.embed("Artist: #{name}. Genres: #{genres}. Vinyls: #{name}")
    update(embedding: embedding.vectors)
  end
end
