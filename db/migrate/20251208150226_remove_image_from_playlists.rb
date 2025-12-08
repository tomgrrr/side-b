class RemoveImageFromPlaylists < ActiveRecord::Migration[7.1]
  def change
    remove_column :playlists, :image, :string
  end
end
