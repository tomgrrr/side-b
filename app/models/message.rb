class Message < ApplicationRecord
  belongs_to :chat
  has_one_attached :file

end
