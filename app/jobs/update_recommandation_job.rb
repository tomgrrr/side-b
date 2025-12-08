class UpdateRecommandationJob < ApplicationJob
  queue_as :default

  def perform(*args)
    VinylRecommandation.destroy_all

    @matches = Match.where(category: "collection")
    embedding = RubyLLM.embed(Match.user_taste(@matches))
    
    @first_vinyls = Vinyl.nearest_neighbors(:embedding, embedding.vectors, distance: "euclidean").first(15)

  end
end
