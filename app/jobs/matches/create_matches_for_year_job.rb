module Matches
  class CreateMatchesForYearJob < ApplicationJob
    queue_as :default

    def perform(year)
      puts "📆 Processing ATP matches for year #{year}..."

      TournamentYear.where(tournament_year: year).find_each do |tournament|
        CreateMatchesForTournamentJob.perform_later(tournament.tournament_slug, tournament.tournament_reference, year)
      end

      puts "✅ Finished enqueuing ATP Matches for year #{year}."
    end
  end
end

