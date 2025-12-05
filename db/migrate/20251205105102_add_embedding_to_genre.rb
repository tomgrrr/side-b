class AddEmbeddingToGenre < ActiveRecord::Migration[7.1]
  def change
    add_column :genres, :embedding, :vector, limit: 1536
  end
end
