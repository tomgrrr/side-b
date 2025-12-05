class AddDiscogsIdToArtists < ActiveRecord::Migration[7.1]
  def change
    add_column :artists, :discogs_id, :integer
  end
end
