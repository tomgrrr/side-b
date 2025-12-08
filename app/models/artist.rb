class Artist < ApplicationRecord
  has_many :artists_vinyls
  has_many :artist_genres
  has_many :genres, through: :artist_genres
  has_many :vinyls, through: :artists_vinyls

  has_neighbors :embedding
  after_create :set_embedding

  def self.split_artists(name)
    return [] if name.blank?

    separators = [
      '/', ',', '&', ' and ', ' vs ', ' vs. ',
      ' feat ', ' feat. ', ' ft ', ' ft. ',
      ' featuring '
    ]

    regex = Regexp.union(separators.map { |s| Regexp.new(Regexp.escape(s), true) })

    name.split(regex)
        .map(&:strip)
        .reject(&:empty?)
        .map { |a| a.squeeze(" ") }
        .map { |a| a.split.map(&:capitalize).join(" ") }
        .uniq
  end

  private


  def set_embedding
    embedding = RubyLLM.embed("Artist: #{name}. Genres: #{genres}. Vinyls: #{vinyls}")
    update(embedding: embedding.vectors)
  end
end
