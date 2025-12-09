class Message < ApplicationRecord
  belongs_to :chat
  has_one_attached :file
  after_create_commit :broadcast_append_to_chat

  private


def broadcast_append_to_chat
  broadcast_append_to chat, target: "messages", partial: "messages/message", locals: { message: self }
end

end
