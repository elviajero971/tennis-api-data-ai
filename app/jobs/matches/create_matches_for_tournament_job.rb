module Matches
  class CreateMatchesForTournamentJob < ApplicationJob
    queue_as :default

    def perform(slug, reference, year)
      puts "🎾 Creating matches for tournament #{slug} (#{year})..."

      Matches::CreateOrUpdateAtpMatchesFromTournamentData.call(slug: slug, reference: reference, year: year)

      puts "✅ Finished creating matches for tournament #{slug} (#{year})."
    end
  end
end
