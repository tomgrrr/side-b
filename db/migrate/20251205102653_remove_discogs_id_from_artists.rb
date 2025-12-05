class RemoveDiscogsIdFromArtists < ActiveRecord::Migration[7.1]
  def change
    remove_column :artists, :discogs_id, :integer
  end
end
