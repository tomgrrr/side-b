class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
    @matches = Match.where(category: "collection")
    embedding = RubyLLM.embed(Match.user_taste(@matches))
    @vinyls = Vinyl.nearest_neighbors(:embedding, embedding.vectors, distance: "euclidean").first(5)
  end
end
