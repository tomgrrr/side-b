class Match < ApplicationRecord
  belongs_to :vinyl
  belongs_to :user
  belongs_to :playlist, optional: true

  has_neighbors :embedding
  after_create :set_embedding

  def total_value(array)
    total = 0
    array.each do |a|
      total = a.vinyl.price
    end
    total
  end

  # def user_taste(matches)
  #   titles = ""
  #   genres = ""
  #   artists = ""

  #   #matches.each do |match|
  #    # titles += match.vinyl.title
  #     #genres += match.vinyl.genre
  #     #artists += match.vinyl.artist
  #   #end
  # end

  def self.user_taste(matches)
    prompt = matches.map do |match|
      genres = Genre.clean(match.vinyl.genres).join(", ")
      artists = match.vinyl.artists.flat_map { |a| Artist.split_artists(a.name) }.uniq.join(", ")
      "genres: #{genres} — artists: #{artists} — vinyl: #{match.vinyl.name}"
    end.join(", ")
    prompt
  end

  private

  def set_embedding
    collection_vinyls = user.matches.where(category: "collection")
    wishlist_vinyls   = user.matches.where(category: "wishlist")

    embedding = RubyLLM.embed("Vinyls in my collection: #{collection_vinyls.join(', ')}. Vinyls in my wishlist: #{wishlist_vinyls.join(', ')}")

    update(embedding: embedding.vectors)
  end
end
