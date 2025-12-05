class AddEmbeddingToMatches < ActiveRecord::Migration[7.1]
  def change
    add_column :matches, :embedding, :vector, limit: 1536
  end
end
