class AddImageToVinyl < ActiveRecord::Migration[7.1]
  def change
    add_column :vinyls, :image, :string
    add_column :vinyls, :price, :float
    rename_column :vinyls, :label, :notes
  end
end
