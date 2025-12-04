class MatchesController < ApplicationController
  before_action :authenticate_user!

  def create
    @vinyl = Vinyl.find(params[:vinyl_id])
    @match = Match.new(
      vinyl: @vinyl,
      user: current_user,
      category: params[:category]
    )

    if @match.save
      redirect_to vinyl_path(@vinyl), notice: "Vinyl ajouté à votre #{params[:category]} !"
    end
  end

  def destroy
    @match = Match.find(params[:id])

    if @match.user == current_user
      @match.destroy
      redirect_back(fallback_location: root_path, notice: "Vinyl retiré.")
    else
      redirect_to root_path, alert: "Action non autorisée."
    end
  end
end
