module PlayerRankings
  require 'yaml'
  class CreateOrUpdatePlayerRankingOpenEra
    include Service

    def initialize(batch_size: 50)
      @batch_size = batch_size
    end

    def call
      puts "⏳ Starting the bulk scraping process..."

      TimeTracker::ProcessTimeTracker.track("Update all player rankings data") do
        tournament_dates.each_slice(@batch_size) do |batch|
          ::PlayerRankings::PlayerRankingsBatchJob.perform_later(batch)
        end
      end

      puts "✅ Finished bulk scraping process."
    end

    private

    def tournament_dates
      @tournament_dates ||= YAML.load_file(Rails.root.join('config', 'tournament_dates.yml'))['dates']
    end

    attr_reader :start_date, :end_date, :batch_size
  end
end