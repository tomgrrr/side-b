class AddTypeToCollections < ActiveRecord::Migration[7.1]
  def change
    add_column :collections, :type, :string
  end
end
