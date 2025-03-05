class ProcessChatMessageJob < ApplicationJob
  queue_as :default

  def perform(user_message, assistant_message)
    user_message_content = user_message.content

    sql_query = Ai::SqlQueryGenerator.new(user_message_content).call

    if sql_query.include?("Sorry")
      assistant_message.update!(content: sql_query)
      return
    end

    result = execute_sql_query(sql_query)

    formatted_answer = Ai::ResultFormatter.new(result).call

    assistant_message.update!(content: formatted_answer)
  end

  private

  def execute_sql_query(sql_query)
    ActiveRecord::Base.connection.execute(sql_query)
  rescue => e
    puts "Error executing SQL query: #{e.message}"
    nil
  end
end