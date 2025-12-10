class SearchController < ApplicationController
  def index
    @vinyls = Vinyl.all
    @query = params[:query]
    if @query.present?
        sql_subquery = <<~SQL
        vinyls.name ILIKE :query
        OR artists.name ILIKE :query
      SQL
      @vinyls = @vinyls.joins(:artists).where(sql_subquery,query: "%#{@query}%")
    end
  end
end
