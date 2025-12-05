class AddEmbeddingToArtists < ActiveRecord::Migration[7.1]
  def change
    add_column :artists, :embedding, :vector, limit: 1536
  end
end
