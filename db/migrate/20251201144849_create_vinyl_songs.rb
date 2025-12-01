class CreateVinylSongs < ActiveRecord::Migration[7.1]
  def change
    create_table :vinyl_songs do |t|
      t.integer :number
      t.references :vinyl, null: false, foreign_key: true
      t.string :name
      t.integer :duration

      t.timestamps
    end
  end
end
