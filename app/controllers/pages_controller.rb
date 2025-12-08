class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
<<<<<<< HEAD
    @vinyls = VinylRecommandation.all.map { |vr| vr.vinyl }.first(4)
=======
    @matches = Match.where(category: "collection")
    embedding = RubyLLM.embed(Match.user_taste(@matches))
    @vinyls = Vinyl.nearest_neighbors(:embedding, embedding.vectors, distance: "euclidean").first(5)
>>>>>>> master
  end
end
