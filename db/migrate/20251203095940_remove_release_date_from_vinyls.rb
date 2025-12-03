class RemoveReleaseDateFromVinyls < ActiveRecord::Migration[7.1]
  def change
    remove_column :vinyls, :release_date, :date
  end
end
