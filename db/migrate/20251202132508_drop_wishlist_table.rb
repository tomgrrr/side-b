class DropWishlistTable < ActiveRecord::Migration[7.1]
  def change
    drop_table :wishlists
  end
end
