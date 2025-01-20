module Tournaments
  class CreateOrUpdateTournamentsPerYearData
    include Service

    def initialize(year:)
      @year = year
    end

    def call
      puts "Starting the tournaments data scraping process for year: #{year}..."

      tournaments_year_data = Tournaments::AtpTournamentsPerYearScraper.new(year).fetch_tournaments_year_data

      tournaments_year_data.each do |tournament_year|
        tournament_year_data = {
          tournament_name: tournament_year[:tournament_name],
          tournament_year: year,
          tournament_slug: tournament_year[:tournament_slug],
          tournament_reference: tournament_year[:tournament_reference],
          tournament_category: tournament_year[:tournament_category],
          tournament_type: tournament_year[:tournament_type],
          tournament_winner_single_tennis_player_slug: tournament_year[:tournament_winner_single_tennis_player_slug]
        }

        tournament_year = TournamentYear.find_or_initialize_by(tournament_year: year, tournament_slug: tournament_year[:tournament_slug])

        tournament_year.update!(tournament_year_data)
      end

      puts "Finished tournaments data scraping process for year: #{year}."
    end

    private

    attr_reader :year
  end
end
