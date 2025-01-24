module Matches
  require "parallel"
  class CreateOrUpdateAtpMatchesFromYearData
    include Service

    def initialize(year)
      @year = year
    end

    def call
      TimeTracker::ProcessTimeTracker.track("Matches data scraping process for year: #{year}") do
        tournaments = TournamentYear.where(tournament_year: year)

        Parallel.each(tournaments, in_threads: Parallel.processor_count) do |tournament_year|
          TimeTracker::ProcessTimeTracker.track("Processing tournament: #{tournament_year.tournament_name}") do
            Matches::CreateOrUpdateAtpMatchesFromTournamentData.call(
              slug: tournament_year.tournament_slug,
              reference: tournament_year.tournament_reference,
              year: year
            )
          end
        end
      end
    end

    private

    attr_reader :year
  end
end
