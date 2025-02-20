module Ai
  class SqlQueryGenerator
    def initialize(question)
      @question = question
    end

    def call
      prompt = <<~PROMPT
        #{database_schema}
        Here is a question: "#{@question}"
        You have multiple tasks to do:
        1 - Translate this question into an SQL query to retrieve the correct data from the database.
        2 - Respond with only the SQL query as a plain string, without any formatting like backticks or code blocks.
        3 - If you don't find any data, respond with this message: "Sorry, no data was found for your query."

        Example: SELECT * FROM tennis_players WHERE full_name = 'Roger Federer'
      PROMPT

      client = Ai::ChatGptClient.new
      client.chat(prompt)
    end

    private

    def database_schema
      <<~SCHEMA
        You are working with a database of tennis data. The schema is as follows:

        - Table: tennis_players
          - full_name: string
          - date_of_birth: date
          - height: integer (in cm)
          - tennis_player_slug: string (unique)
          - player_url: string
          - career_highest_ranking: integer
          - career_highest_ranking_date: date
          - career_prize_money: decimal (precision: 15, scale: 2)
          - playing_style: string
          - age: integer
          - weight: integer (in kg)
          - place_of_birth: string
          - current_coach: string
          - nb_career_titles: integer
          - nb_career_wins: integer
          - nb_career_losses: integer
          - nb_career_matches: integer

        - Table: player_rankings
          - tennis_player_id: integer (foreign key)
          - week_date: date
          - ranking: integer
          - created_at: datetime
          - updated_at: datetime

        - Table: matches
          - tournament_year_id: integer (foreign key)
          - tournament_slug: string
          - tournament_reference: string
          - round: string
          - duration: integer (in minutes)
          - year_of_tournament: integer
          - player_1_id: integer (foreign key)
          - player_2_id: integer (foreign key)
          - player_winner_id: integer (foreign key)
          - player_1_slug: string
          - player_2_slug: string
          - player_winner_slug: string
          - score: string
          - ending: string
          - created_at: datetime
          - updated_at: datetime

        - Table: tournament_years
          - tournament_reference: string
          - tournament_slug: string
          - tournament_name: string
          - tournament_category: string
          - tournament_type: string
          - tournament_winner_single_tennis_player_slug: string
          - tournament_year: integer
          - created_at: datetime
          - updated_at: datetime
      SCHEMA
    end
  end
end
