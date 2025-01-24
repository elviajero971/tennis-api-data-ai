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
      player_slugs = matches_data.flat_map { |match| [match[:player_1_slug], match[:player_2_slug], match[:player_winner_slug]] }.uniq
      TennisPlayer.where(tennis_player_slug: player_slugs).index_by(&:tennis_player_slug)
    end

    def preload_tournament_year
      TournamentYear.find_or_create_by!(
        tournament_year: year,
        tournament_reference: reference,
        tournament_slug: slug
      )
    end

    def prepare_match_data(match_data, existing_players, tournament_year)
      player_1 = existing_players[match_data[:player_1_slug]] || create_player(match_data[:player_1_slug])
      player_2 = existing_players[match_data[:player_2_slug]] || create_player(match_data[:player_2_slug])
      player_winner = existing_players[match_data[:player_winner_slug]] || create_player(match_data[:player_winner_slug])

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
        year_of_tournament: year,
        created_at: Time.now,
        updated_at: Time.now
      }
    rescue StandardError => e
      puts "Error preparing match data: #{e.message}"
      nil
    end

    def create_player(player_slug)
      player = TennisPlayer.create!(tennis_player_slug: player_slug)
      puts "Created player: #{player_slug}"
      player
    rescue StandardError => e
      puts "Error creating player: #{e.message}"
      nil
    end
  end
end
