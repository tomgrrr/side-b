class MakePlaylistIdNullableInMatches < ActiveRecord::Migration[7.1]
  def change
    change_column_null :matches, :playlist_id, true
  end
end
