module PlayerRankings
  class PlayerRankingWeekJob < ApplicationJob
    queue_as :default

    def perform(rank_range, week_date)
      puts "⏳ Fetching rankings for week: #{week_date}..."

      PlayerRankings::CreateOrUpdatePlayerRankingWeek.call(rank_range, week_date)

      puts "✅ Successfully updated rankings for week: #{week_date}."
    rescue StandardError => e
      puts "❌ Error updating rankings for week #{week_date}: #{e.message}"
    end
  end
end
