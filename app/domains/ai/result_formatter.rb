module Ai
  class ResultFormatter
    def initialize(result)
      @result = result
    end

    def call
      prompt = <<~PROMPT
        Here is the result of a database query:
        #{@result}
        Format the result into a natural language sentence to answer the user's question.
      PROMPT

      client = Ai::ChatGptClient.new
      client.chat(prompt)
    end
  end
end
