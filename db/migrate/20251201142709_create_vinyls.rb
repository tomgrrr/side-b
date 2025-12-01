class CreateVinyls < ActiveRecord::Migration[7.1]
  def change
    create_table :vinyls do |t|
      t.string :name
      t.date :release_date
      t.string :songs
      t.string :label

      t.timestamps
    end
  end
end
