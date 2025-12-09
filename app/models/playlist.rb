class Playlist < ApplicationRecord
  has_many :matches
  has_one_attached :image
  
end
