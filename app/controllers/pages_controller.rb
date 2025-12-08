class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
    @matches = Match.where(category: "collection")
    embedding = RubyLLM.embed(Match.user_taste(@matches))
    @first_vinyls = Vinyl.nearest_neighbors(:embedding, embedding.vectors, distance: "euclidean")
    raise
    @vinyls = @first_vinyls.reject { |vinyl| @matches.exists?(vinyl_id: vinyl.id) }
  end
end
