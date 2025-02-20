module Ai
  class ChatGptClient
    def initialize(model: "gpt-4o", api_key: ENV["OPENAI_API_KEY"])
      @model = model
      @client = OpenAI::Client.new(access_token: api_key)
    end

    def chat(prompt)
      response = @client.chat(
        parameters: {
          model: @model,
          messages: [
            { role: "system", content: "You are an AI assistant." },
            { role: "user", content: prompt }
          ]
        }
      )
      response["choices"].first["message"]["content"].strip
    end
  end
end
