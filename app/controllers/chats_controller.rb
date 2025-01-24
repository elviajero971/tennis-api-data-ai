class ChatsController < ApplicationController
  def index
    @chat = Chat.first_or_create!(name: "Default Chat")
    @messages = @chat.messages.order(created_at: :asc)
  end

  def create_message
    @chat = Chat.first_or_create!(name: "Default Chat")
    user_message = @chat.messages.create!(content: params[:message], role: "user")

    # Provide context about the database to the AI
    database_schema = <<~SCHEMA
      You are working with a database of tennis players. The schema is as follows:
      - Table: tennis_players
        - full_name: string
        - date_of_birth: date
        - height: integer (in cm)
        - handedness: string ("right" or "left")
        - backhand: string ("one-handed" or "two-handed")
    SCHEMA

    prompt = <<~PROMPT
      #{database_schema}
      Here is a question: "#{user_message.content}"
      You have multiple tasks to do:
      1 - Translate this question into an SQL query to retrieve the correct data from the database.
      2 - Respond with only the SQL query as a plain string, without any formatting like backticks or code blocks.
      3 - If you don't find any data, respond with this message: "Sorry, no data was found for your query."

      Example: SELECT * FROM tennis_players WHERE full_name = 'Roger Federer'
    PROMPT

    client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])
    response = client.chat(
      parameters: {
        model: "gpt-4o",
        messages: [
          { role: "system", content: "You are an AI assistant that helps with database queries." },
          { role: "user", content: prompt }
        ]
      }
    )

    sql_query = response["choices"].first["message"]["content"]

    # Clean up the SQL query to remove any extra formatting
    sql_query = response["choices"].first["message"]["content"].strip
    sql_query = sql_query.gsub(/```sql|```/, "").strip # Remove markdown formatting like ```sql```

    puts "sql_query: #{sql_query}"

    begin
      result = ActiveRecord::Base.connection.execute(sql_query)
    rescue => e
      result = { error: "There was an error with the query: #{e.message}" }
    end

    puts "result: #{result}"

    if result.any?
      formatting_prompt = <<~PROMPT
        Here is the result of a database query:
        #{result}
        Format the result into a natural language sentence to answer the user's question.
      PROMPT

      formatting_response = client.chat(
        parameters: {
          model: "gpt-4o",
          messages: [
            { role: "system", content: "You are an assistant that formats database results into user-friendly sentences." },
            { role: "user", content: formatting_prompt }
          ]
        }
      )

      formatted_answer = formatting_response["choices"].first["message"]["content"].strip
    else
      formatted_answer = "Sorry, no data was found for your query."
    end

    assistant_message = @chat.messages.create!(content: formatted_answer, role: "assistant")

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.append("messages", partial: "messages/message", locals: { message: assistant_message }) }
      format.html { redirect_to chats_path }
    end
  end
end
