class AddUserReferencesToVinylRecommandation < ActiveRecord::Migration[7.1]
  def change
    add_reference :vinyl_recommandations, :user, null: false, foreign_key: true
  end
end
