class Match < ApplicationRecord
  belongs_to :vinyl
  belongs_to :user
  belongs_to :playlists
end
