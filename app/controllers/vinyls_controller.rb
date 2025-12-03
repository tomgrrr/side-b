class VinylsController < ApplicationController

  def show
     @vinyl = Vinyl.find(params[:id])
  end

  def index
       @vinyl = Vinyl.all
  end
end
