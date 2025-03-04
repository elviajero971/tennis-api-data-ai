class RemoveChatsAndChatIdFromMessages < ActiveRecord::Migration[8.0]
  def change
    # Remove the foreign key constraint from messages to chats, if it exists.
    remove_foreign_key :messages, :chats

    # Remove the index on chat_id if it exists.
    remove_index :messages, :chat_id if index_exists?(:messages, :chat_id)

    # Remove the chat_id column from messages.
    remove_column :messages, :chat_id, :integer

    # Drop the chats table.
    drop_table :chats
  end
end