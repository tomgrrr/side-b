class PlaylistsController < ApplicationController

  def index
    @playlists = Playlist.all
  end

  def show
    @playlist = Playlist.find(params[:id])
  end

  def create
    @playlist = Playlist.new(playlist_params)

    if @playlist.save
      redirect_back fallback_location: root_path, notice: "Playlist créée avec succès!"
    else
      redirect_back fallback_location: root_path, alert: "Erreur lors de la création de la playlist"
    end
  end

   private

  def playlist_params
    params.require(:playlist).permit(:name, :image)
  end

end
