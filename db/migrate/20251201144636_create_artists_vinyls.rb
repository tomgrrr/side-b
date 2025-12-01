class CreateArtistsVinyls < ActiveRecord::Migration[7.1]
  def change
    create_table :artists_vinyls do |t|
      t.references :artist, null: false, foreign_key: true
      t.references :vinyl, null: false, foreign_key: true

      t.timestamps
    end
  end
end
