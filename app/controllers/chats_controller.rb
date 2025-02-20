class ChatsController < ApplicationController
  def index
    @chat = Chat.first_or_create!(name: "Default Chat")
    @messages = @chat.messages.order(created_at: :asc)
  end

  def create_message
    @chat = Chat.first_or_create!(name: "Default Chat")

    # Create the user message and immediately append it to the chat
    user_message = @chat.messages.create!(content: params[:message], role: "user")

    # Create a placeholder for the assistant message
    placeholder_message = @chat.messages.create!(content: "Processing...", role: "assistant")

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.append("messages", partial: "messages/message", locals: { message: user_message }),
          turbo_stream.append("messages", partial: "messages/message", locals: { message: placeholder_message })
        ]
      end
    end

    Thread.new do
      # Step 1: Generate SQL query
      sql_query = Ai::SqlQueryGenerator.new(user_message.content).call
      puts "Generated SQL Query: #{sql_query}"

      # Step 2: Execute SQL query
      result = execute_sql_query(sql_query)

      # Step 3: Format result into a user-friendly response
      formatted_answer =  "Sorry, no data was found for your query."

      if result.is_a?(Array) && result.any?
        formatted_answer = Ai::ResultFormatter.new(result).call
      end

      # Update the placeholder message with the assistant's response
      placeholder_message.update!(content: formatted_answer)

      # Broadcast the updated message
      Turbo::StreamsChannel.broadcast_update_to(
        "messages",
        target: "message_#{placeholder_message.id}",
        partial: "messages/message",
        locals: { message: placeholder_message }
      )

      puts "Broadcasted Turbo Stream for message: #{placeholder_message.id}"

    end
  end

  private

  def execute_sql_query(sql_query)
    ActiveRecord::Base.connection.execute(sql_query)
  rescue => e
    puts "Error executing SQL query: #{e.message}"
    nil
  end
end
