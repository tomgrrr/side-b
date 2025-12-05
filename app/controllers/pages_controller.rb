class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
    @vinyls = Vinyl.where.not(id: Match.select(:vinyl_id))
  end
end
