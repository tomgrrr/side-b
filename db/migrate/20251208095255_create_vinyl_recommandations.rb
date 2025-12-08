class CreateVinylRecommandations < ActiveRecord::Migration[7.1]
  def change
    create_table :vinyl_recommandations do |t|
      t.references :vinyl, null: false, foreign_key: true

      t.timestamps
    end
  end
end
