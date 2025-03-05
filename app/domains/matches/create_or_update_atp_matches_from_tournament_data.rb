require "parallel"

module Matches
  class CreateOrUpdateAtpMatchesFromTournamentData
    include Service

    def initialize(slug:, reference:, year:)
      @slug = slug
      @reference = reference
      @year = year
    end

    def call
      puts "Fetching matches data for tournament #{slug} (#{year})..."

      matches_data = Matches::AtpMatchesFromTournamentScraper.new(slug: slug, reference: reference, year: year).fetch

      return if matches_data.empty?

      # Preload existing players and tournament years
      existing_players = preload_players(matches_data)
      tournament_year = preload_tournament_year

      # Process matches in parallel and group for batch inserts
      processed_matches = Parallel.map(matches_data, in_threads: Parallel.processor_count) do |match_data|
        prepare_match_data(match_data, existing_players, tournament_year)
      end.compact

      # Batch insert or upsert matches
      Match.upsert_all(processed_matches, unique_by: %i[tournament_year_id player_1_id player_2_id])

      puts "Finished processing matches for tournament #{slug} (#{year})."
    end

    private

    attr_reader :slug, :reference, :year

    def preload_players(matches_data)
      player_slugs = matches_data.map { |match| [match[:player_1_slug], match[:player_2_slug], match[:player_winner_slug]] }.flatten.compact.uniq

      # 🔥 Fix: Avoid failure when a player is missing
      TennisPlayer.where(tennis_player_slug: player_slugs).index_by(&:tennis_player_slug).tap do |players|
        missing_players = player_slugs - players.keys

        missing_players.each do |player_slug|
          players[player_slug] = create_player(player_slug)
        end
      end
    end

    def preload_tournament_year
      TournamentYear.find_or_create_by!(
        tournament_year: year,
        tournament_reference: reference,
        tournament_slug: slug
      )
    end

    def prepare_match_data(match_data, existing_players, tournament_year)
      return nil if match_data[:player_1_slug].nil? || match_data[:player_2_slug].nil? || match_data[:player_winner_slug].nil?

      # 🔥 Fix: Create missing players and update hash
      player_1 = existing_players[match_data[:player_1_slug]] || (existing_players[match_data[:player_1_slug]] = create_player(match_data[:player_1_slug]))
      player_2 = existing_players[match_data[:player_2_slug]] || (existing_players[match_data[:player_2_slug]] = create_player(match_data[:player_2_slug]))
      player_winner = existing_players[match_data[:player_winner_slug]] || (existing_players[match_data[:player_winner_slug]] = create_player(match_data[:player_winner_slug]))

      return nil unless player_1 && player_2 && player_winner # Ensure all players exist

      {
        tournament_year_id: tournament_year.id,
        player_1_id: player_1.id,
        player_2_id: player_2.id,
        player_winner_id: player_winner.id,
        tournament_slug: match_data[:tournament_slug],
        tournament_reference: match_data[:tournament_reference],
        round: match_data[:round],
        duration: match_data[:duration],
        player_1_slug: match_data[:player_1_slug],
        player_2_slug: match_data[:player_2_slug],
        player_winner_slug: match_data[:player_winner_slug],
        score: match_data[:match_score],
        year_of_tournament: year,
        created_at: Time.now,
        updated_at: Time.now,
        ending: match_ending(match_data[:duration], match_data[:match_score]),
        match_stats_id: match_data[:match_stats_id]
      }
    rescue StandardError => e
      puts "Error preparing match data: #{e.message}"
      nil
    end

    def create_player(player_slug)
      return nil if player_slug.nil?

      player = TennisPlayer.create!(tennis_player_slug: player_slug)
      puts "Created player: #{player_slug}"
      player
    rescue StandardError => e
      puts "Error creating player: #{e.message}"
      nil
    end

    def match_ending(duration, score)
      return "walkover" if (duration.nil? || duration == 0) && score.nil?
      "completed"
    end

    def match_finished?(score, best_of_five: false)
      sets = score.split(" ")

      # Count sets won by each player
      player_1_wins = 0
      player_2_wins = 0

      sets.each do |set|
        scores = set.scan(/\d+/).map(&:to_i)

        if scores.length == 2 # Normal set
          p1, p2 = scores

          if p1 > p2
            player_1_wins += 1
          else
            player_2_wins += 1
          end
        end
      end

      # Determine required number of sets to win
      sets_to_win = best_of_five ? 3 : 2

      # A match is finished if one player reaches the required sets
      match_completed = (player_1_wins == sets_to_win || player_2_wins == sets_to_win)

      # Check for incomplete sets (possible retirement)
      last_set = sets.last.scan(/\d+/).map(&:to_i)

      match_retired = !match_completed || last_set.any? { |score| score < 6 && score != 0 }

      match_completed && !match_retired
    end
  end
end