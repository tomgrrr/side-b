class AddReleaseDateToVinyls < ActiveRecord::Migration[7.1]
  def change
    add_column :vinyls, :release_date, :integer
  end
end
