module PlayerRankings
  class PlayerRankingsBatchJob < ApplicationJob
    queue_as :default

    def perform(week_dates)
      week_dates.each do |week_date|
        ::PlayerRankings::PlayerRankingWeekJob.perform_later("0-100", week_date)
      end
    rescue StandardError => e
      puts "❌ Error processing batch: #{e.message}"
    end
  end
end

