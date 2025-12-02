class RenameCollectionsToMatches < ActiveRecord::Migration[7.1]
  def change
    rename_table :collections, :matches
  end
end
