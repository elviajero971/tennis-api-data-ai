class Message < ApplicationRecord

  validates :content, presence: true, length: { minimum: 3 }

  after_create_commit do
    broadcast_append_to "messages", target: "messages", partial: "messages/message", locals: { message: self }
  end

  after_update_commit do
    broadcast_replace_to "messages", target: "message_#{id}", partial: "messages/message", locals: { message: self }
  end
end
