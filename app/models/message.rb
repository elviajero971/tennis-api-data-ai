class Message < ApplicationRecord
  belongs_to :chat

  after_create_commit do
    broadcast_append_to "messages", target: "messages", partial: "messages/message", locals: { message: self }
  end
end
