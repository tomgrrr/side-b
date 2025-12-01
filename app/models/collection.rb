class Collection < ApplicationRecord
  belongs_to :vinyl
  belongs_to :user
  has_many :playlists, dependent: :destroy
end
