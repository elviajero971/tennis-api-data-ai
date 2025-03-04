class ProcessChatMessageJob < ApplicationJob
  queue_as :default

  def perform(user_message, assistant_message)
    user_message_content = user_message.content

    sql_query = Ai::SqlQueryGenerator.new(user_message_content).call

    if sql_query.include?("Sorry")
      assistant_message.update!(content: sql_query)
      return
    end

    puts "Executing SQL query: #{sql_query}"

    result = execute_sql_query(sql_query)



    puts "Result of sql query: #{result}"

    formatted_answer = Ai::ResultFormatter.new(result).call

    puts "Formatted answer: #{formatted_answer}"

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