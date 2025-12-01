class CreateVinylsGenres < ActiveRecord::Migration[7.1]
  def change
    create_table :vinyls_genres do |t|
      t.references :genre, null: false, foreign_key: true
      t.references :vinyl, null: false, foreign_key: true

      t.timestamps
    end
  end
end
