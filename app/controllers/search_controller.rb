class SearchController < ApplicationController
  def index
    @query = params[:query]
    if @query.present?
      @artists = Artist.where("name ILIKE ?", "%#{@query}%")
      @vinyls = Vinyl.where("name ILIKE ?", "%#{@query}%")
    end
  end
end
