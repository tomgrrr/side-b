class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
    @vinyls = VinylRecommandation.all.map { |vr| vr.vinyl }.first(4)
    @featured_vinyls = Vinyl.order("RANDOM()").limit(4)
  end
end
