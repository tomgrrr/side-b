class AddImageToPlaylist < ActiveRecord::Migration[7.1]
  def change
    add_column :playlists, :image, :string
  end
end
