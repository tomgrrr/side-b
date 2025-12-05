class AddEmbeddingToVinyls < ActiveRecord::Migration[7.1]
  def change
    add_column :vinyls, :embedding, :vector, limit: 1536
  end
end
