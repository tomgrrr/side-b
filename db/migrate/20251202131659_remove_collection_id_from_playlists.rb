class RemoveCollectionIdFromPlaylists < ActiveRecord::Migration[7.1]
  def change
    remove_reference :playlists, :collection, foreign_key: true
  end
end
