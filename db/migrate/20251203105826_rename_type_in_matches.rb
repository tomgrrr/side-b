class RenameTypeInMatches < ActiveRecord::Migration[7.1]
  def change
    rename_column :matches, :type, :category
  end
end
