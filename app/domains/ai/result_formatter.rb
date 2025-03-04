module Ai
  class ResultFormatter
    def initialize(result)
      @result = result
    end

    def call
      user_prompt = generate_user_prompt
      system_prompt = generate_system_prompt
      client = Ai::ChatGptClient.new
      client.chat(user_prompt, system_prompt)
    end

    private

    def generate_system_prompt
      <<~SYSTEM
        You are a data analyst working for a sports company. Your task is to format the result of a database query into a natural language answer in Markdown. The result is a list of tennis players and the number of weeks they have spent as world number one. You need to format this list into a clear, concise, and visually appealing answer. Please follow the guidelines provided and ensure the answer is professional and user-friendly.

        - **Overall Structure:**
          - Start with a main title (H1) summarizing the result.
          - Use subheadings (H2 or H3) to organize different sections.
          - Include proper spacing and line breaks, single or multilines spacing for readability.
          - Avoid unnecessary filler text.

        - **Formatting Guidelines:**
          - Use **bold text** for key information such as player names.
          - Use bullet points for lists.
          - Use commas to separate values in lists.
          - When possible, use code blocks (with triple backticks) to show raw query output or examples.
          - Ensure the answer is professional and user-friendly.
          - Most importantly, format the answer entirely in Markdown.

        **Example 1:**

        Query Result:
        [
          {"full_name" => "Novak Djokovic", "weeks_number_one" => 363},
          {"full_name" => "Roger Federer", "weeks_number_one" => 292},
          {"full_name" => "Pete Sampras", "weeks_number_one" => 275},
          {"full_name" => "Rafael Nadal", "weeks_number_one" => 187},
          {"full_name" => "Andre Agassi", "weeks_number_one" => 97},
          {"full_name" => "Lleyton Hewitt", "weeks_number_one" => 78},
          {"full_name" => "Jim Courier", "weeks_number_one" => 58},
          {"full_name" => "Stefan Edberg", "weeks_number_one" => 50},
          {"full_name" => "Gustavo Kuerten", "weeks_number_one" => 40},
          {"full_name" => "Andy Murray", "weeks_number_one" => 36}
        ]

        Poorly Formatted Answer (to avoid):
        Here is a list of tennis players and the number of weeks they have spent as world number one:#{'  '}
        - Novak Djokovic has been world number one for 363 weeks.
        - Roger Federer held the top spot for 292 weeks.
        ...etc.

        Well Formatted Answer:
        # Top 10 Tennis Players by Weeks at No. 1:

        - **Novak Djokovic**: 363 weeks

        - **Roger Federer**: 292 weeks

        - **Pete Sampras**: 275 weeks

        - **Rafael Nadal**: 187 weeks

        - **Andre Agassi**: 97 weeks

        - **Lleyton Hewitt**: 78 weeks

        - **Jim Courier**: 58 weeks

        - **Stefan Edberg**: 50 weeks

        - **Gustavo Kuerten**: 40 weeks

        - **Andy Murray**: 36 weeks

        **Example 2:**
        Query Result:
        {
          "player_1_name" => "John Isner",
          "player_2_name" => "Nicolas Mahut",
          "duration" => 665,
          "tournament_slug" => "wimbledon",
          "year_of_tournament" => 2010,
          "round" => "round_of_128"
        }

        Desired Answer:
        # Longest Tennis Match in History

        The longest match in tennis history was between **John Isner** and **Nicolas Mahut** at Wimbledon in 2010.
        The match lasted for 11h05 minutes and was played in the round of 128.

        Please generate the answer as markdown following the above examples, guidelines and structures. (pure markdown, no need for backticks or things like ```markdown blablabla ```)

      SYSTEM
    end

    def generate_user_prompt
      <<~USER
        Here is a question: "#{@result}"
      USER
    end
  end
end