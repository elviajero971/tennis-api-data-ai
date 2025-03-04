module Matches
  class CreateOrUpdateAtpMatchesFromOpenEra
    include Service

    def call
      puts "📅 Processing ATP matches for Open Era (1990 to 2009)..."
      TimeTracker::ProcessTimeTracker.track("Processing all tournaments of Open Era") do

        puts "📅 Processing ATP matches for Open Era (1990-2009)..."

        TournamentYear.where(tournament_category: "atp", tournament_year: 1990..2024).find_each do |tournament|
          CreateMatchesForTournamentJob.perform_later(tournament.tournament_slug, tournament.tournament_reference, tournament.tournament_year)
        end

        puts "✅ Finished enqueuing Open Era ATP Matches."
      end
    end
  end
end