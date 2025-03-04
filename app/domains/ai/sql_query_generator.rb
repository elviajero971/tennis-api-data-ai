module Ai
  class SqlQueryGenerator
    def initialize(question)
      @question = question
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
        You are an SQL Query Generator. Your role is to generate correct SQLite3-compatible SQL queries using the following database schema and rules:

        #{database_schema}

        **Guidelines:**
        1. Respond with only the SQL query as a plain string (no markdown formatting, backticks, or extra text).
        2. Use only SQL features compatible with SQLite3.
        3. If no data is found, respond with: "Sorry, no data was found for your query: *reasons*" (replace *reasons* with the actual reasons).
        4. Include any necessary filtering or conditions.
        5. Exclude any records if required data (e.g. height, weight) is missing or invalid.
        6. If the question contains name of the player, downcase the name and compare it with the full_name column in the tennis_players table, downcase the full_name column as well.

        **Examples:**

        Example 1:
        - If the user asks: "Who are the top 10 tallest players by height?"

        Expected SQL query:
        ```sql
        SELECT full_name, height_in_cm FROM tennis_players ORDER BY height_in_cm DESC LIMIT 10;
        ```

        Example 2:
        - If the user asks: "Who is the player that stayed number one the longest ?"

        Expected SQL query:
        ```sql
          SELECT full_name, COUNT(*) as weeks_number_one
          FROM tennis_players
          JOIN player_rankings ON tennis_players.id = player_rankings.tennis_player_id
          WHERE ranking = 1
          GROUP BY full_name
          ORDER BY weeks_number_one DESC
          LIMIT 1;
        ```

        Example 3:
        - If the user asks: "Which countries has produced the most ATP No.1-ranked players? Give me the first 10 countries."

        Expected SQL query:
        ```sql
          SELECT full_name, COUNT(*) as weeks_number_one
          FROM tennis_players
          JOIN player_rankings ON tennis_players.id = player_rankings.tennis_player_id
          WHERE ranking = 1
          GROUP BY full_name
          ORDER BY weeks_number_one DESC
          LIMIT 10;
        ```

        Example 4:
        - If the user asks: "Who are the 10 longest matches ever?"

        Expected SQL query:
        ```sql
          SELECT player_1.full_name as player_1_name, player_2.full_name as player_2_name, matches.duration, matches.tournament_slug, matches.year_of_tournament, matches.round
          FROM matches
          JOIN tennis_players as player_1 ON matches.player_1_id = player_1.id
          JOIN tennis_players as player_2 ON matches.player_2_id = player_2.id
          ORDER BY matches.duration DESC
          LIMIT 10;
        ```

        Example 5:

        - If the user asks: "Which players have won the most matches with a bagel set (6/0)?"

        Expected SQL query:
        ```sql
              SELECT
                tp.full_name AS player_name,
                COUNT(*) AS total_matches_with_bagel,
                SUM(
                  (LENGTH(m.score) - LENGTH(REPLACE(m.score, '6/0', ''))) / 3
                ) AS total_bagels_given,
                GROUP_CONCAT(
                  m.tournament_slug || ' (' || m.year_of_tournament || '), ' ||
                  m.round || ' - ' || m.score, ' | '
                ) AS match_details
                FROM matches m
                JOIN tennis_players tp ON tp.id = m.player_1_id
                WHERE m.score LIKE '%6/0%'
                GROUP BY tp.full_name
                ORDER BY total_bagels_given DESC
                LIMIT 10;
        ```

        Example 6:
        
        - If the user asks: "Which players have won the most grand slam?"

        Expected SQL query:
# check the tournament_winner_single_tennis_player_slug and tournament_type in the tournament_years table
        ```sql
              SELECT
                tp.full_name AS player_name,
                COUNT(*) AS total_grand_slam_wins,
                GROUP_CONCAT(
                  ty.tournament_name || ' (' || ty.tournament_year || ')', ' | '
                ) AS grand_slam_wins_details
                FROM tournament_years ty
                JOIN tennis_players tp ON tp.tennis_player_slug = ty.tournament_winner_single_tennis_player_slug
                WHERE ty.tournament_type = 'grandslam'
                GROUP BY tp.full_name
                ORDER BY total_grand_slam_wins DESC
                LIMIT 10;
        ```
      PROMPT
      SYSTEM
    end

    def generate_user_prompt
      <<~USER
        Here is a question: "#{@question}"
      USER
    end

    def database_schema
      <<~SCHEMA
      You are working with a database of tennis data. The schema is as follows:

      - Table: tennis_players
        - id: integer (Primary Key)
        - full_name: string (Full name of the player)
        - date_of_birth: date (Date of birth of the player)
        - age: integer (Current age of the player)
        - height_in_cm: integer (Height of the player in centimeters)
        - weight_in_kg: integer (Weight of the player in kilograms)
        - nationality: string (Country the player represents)
        - place_of_birth: string (City and country where the player was born)
        - play_hand: string (Playing hand, e.g., Right-Handed, Left-Handed)
        - back_hand: string (Type of backhand stroke, e.g., One-Handed, Two-Handed)
        - tennis_player_slug: string (Unique identifier for each player, used in URLs)
        - player_url: string (ATP Tour profile link)
        - current_coach: string (Name of the player's coach)
        - active_player: boolean (Indicates if the player is still active, default: true)
        - double_specialist: boolean (Indicates if the player specializes in doubles, default: false)
        - career_prize_money: decimal (precision: 15, scale: 2) (Total career prize money earned in USD)
        - career_highest_ranking_singles: integer (Highest ATP singles ranking achieved)
        - career_highest_ranking_date_singles: date (Date when the player achieved their highest singles ranking)
        - career_highest_ranking_doubles: integer (Highest ATP doubles ranking achieved)
        - career_highest_ranking_date_doubles: date (Date when the player achieved their highest doubles ranking)
        - nb_career_titles_singles: integer (Number of career titles won in singles)
        - nb_career_matches_singles: integer (Total number of singles matches played)
        - nb_career_wins_singles: integer (Number of singles matches won)
        - nb_career_losses_singles: integer (Number of singles matches lost)
        - nb_career_titles_doubles: integer (Number of career titles won in doubles)
        - nb_career_matches_doubles: integer (Total number of doubles matches played)
        - nb_career_wins_doubles: integer (Number of doubles matches won)
        - nb_career_losses_doubles: integer (Number of doubles matches lost)
        - created_at: datetime (Timestamp when the record was created)
        - updated_at: datetime (Timestamp when the record was last updated)

      - Table: player_rankings
        - id: integer (Primary Key)
        - tennis_player_id: integer (Foreign key referencing tennis_players)
        - week_date: date (The week the ranking corresponds to)
        - ranking: integer (Player’s ranking for that week)
        - created_at: datetime (Timestamp when the record was created)
        - updated_at: datetime (Timestamp when the record was last updated)

      - Table: matches
        - id: integer (Primary Key)
        - tournament_year_id: integer (Foreign key referencing tournament_years)
        - tournament_slug: string (Unique identifier for the tournament)
        - tournament_reference: string (Tournament reference ID)
        - round: string (Tournament round, e.g., "finals", "semi_finals", "quarter_finals", "round_of_16", "round_of_32", "round_of_64", "round_of_128")
        - duration: integer (Match duration in minutes)
        - year_of_tournament: integer (Year the tournament took place)
        - player_1_id: integer (Foreign key referencing tennis_players)
        - player_2_id: integer (Foreign key referencing tennis_players)
        - player_winner_id: integer (Foreign key referencing tennis_players, nullable)
        - player_1_slug: string (Slug for Player 1)
        - player_2_slug: string (Slug for Player 2)
        - player_winner_slug: string (Slug for the winner, nullable)
        - score: string (Match score in sets format, e.g., "6/3 6/4")
        - ending: string (Match ending type, e.g., "completed", "retired", "walkover")
        - match_stats_id: string (ID referencing match statistics)
        - created_at: datetime (Timestamp when the record was created)
        - updated_at: datetime (Timestamp when the record was last updated)

      - Table: tournament_years
        - id: integer (Primary Key)
        - tournament_reference: string (Tournament reference ID)
        - tournament_slug: string (Unique identifier for the tournament)
        - tournament_name: string (Name of the tournament, e.g., "Roland Garros")
        - tournament_category: string (Category of the tournament, e.g., "atp", "challenger")
        - tournament_type: string (Type of tournament, e.g., "grandslam", "1000", "500", "250")
        - tournament_winner_single_tennis_player_slug: string (Slug of the player who won the tournament)
        - tournament_year: integer (Year of the tournament)
        - created_at: datetime (Timestamp when the record was created)
        - updated_at: datetime (Timestamp when the record was last updated)

        Foreign Key Relationships:
        - player_rankings.tennis_player_id → tennis_players.id
        - matches.tournament_year_id → tournament_years.id
        - matches.player_1_id → tennis_players.id
        - matches.player_2_id → tennis_players.id
        - matches.player_winner_id → tennis_players.id
      SCHEMA
    end
  end
end
