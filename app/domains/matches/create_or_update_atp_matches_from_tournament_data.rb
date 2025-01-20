module Matches
  class CreateOrUpdateAtpMatchesFromTournamentData
    include Service

    def initialize(slug:, reference:, year:)
      @slug = slug
      @reference = reference
      @year = year
    end

    def call
      matches_data = Matches::AtpMatchesFromTournamentScraper.new(slug: slug, reference: reference, year: year).fetch

      return if matches_data.empty?
      matches_data.each do |match_data|
        player_1 = TennisPlayer.find_or_create_by!(tennis_player_slug: match_data[:player_1_slug])
        player_2 = TennisPlayer.find_or_create_by!(tennis_player_slug: match_data[:player_2_slug])
        player_winner = TennisPlayer.find_or_create_by!(tennis_player_slug: match_data[:player_winner_slug])

        puts "Creating match between #{player_1.id} and #{player_2.id}..."
        tournament_year = TournamentYear.find_or_create_by!(
          tournament_year: year,
          tournament_reference: match_data[:tournament_reference],
          tournament_slug: match_data[:tournament_slug]
        )

        Match.where(
          tournament_year_id: tournament_year.id,
          player_1_id: player_1.id,
          player_2_id: player_2.id,
          year_of_tournament: year
        ).first_or_create!(
          tournament_year_id: tournament_year.id,
          player_1_id: player_1.id,
          player_2_id: player_2.id,
          tournament_slug: match_data[:tournament_slug],
          tournament_reference: match_data[:tournament_reference],
          round: match_data[:round],
          duration: match_data[:duration],
          player_winner_id: player_winner.id,
          player_1_slug: match_data[:player_1_slug],
          player_2_slug: match_data[:player_2_slug],
          player_winner_slug: match_data[:player_winner_slug],
          year_of_tournament: year
        )
      end

    end

    private

    attr_reader :slug, :reference, :year
  end
end
