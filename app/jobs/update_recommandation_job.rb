class UpdateRecommandationJob < ApplicationJob
  queue_as :default

  def perform

    User.all.each do |user|
      user.vinyl_recommandations.destroy_all

      @matches = Match.where(category: "collection", user: user)
      embedding = RubyLLM.embed(Match.user_taste(@matches))

      @first_vinyls = Vinyl.nearest_neighbors(:embedding, embedding.vectors, distance: "euclidean").first(15)

     @first_vinyls.each { |vinyl| VinylRecommandation.create!(vinyl: vinyl, user: user) }
    end

  end
end
