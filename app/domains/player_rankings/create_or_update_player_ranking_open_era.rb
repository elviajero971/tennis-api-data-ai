module PlayerRankings
  class CreateOrUpdatePlayerRankingOpenEra
    include Service

    def initialize(start_date: "2019-01-07", end_date: "2022-12-26")
      @start_date = Date.parse(start_date)
      @end_date = Date.parse(end_date)
    end

    def call
      puts "Starting the bulk scraping process..."
      TimeTracker::ProcessTimeTracker.track("Update all player rankings data") do
        (@start_date..@end_date).step(7).each do |week_date|
          week_date_str = week_date.strftime("%Y-%m-%d")
          puts "Processing week: #{week_date_str}"

          PlayerRankings::CreateOrUpdatePlayerRankingWeek.call("0-100", week_date_str)
        end
      end
      puts "Finished bulk scraping process."
    end
  end
end