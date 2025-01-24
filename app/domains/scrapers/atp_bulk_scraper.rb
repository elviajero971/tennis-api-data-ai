module Scrapers
  class AtpBulkScraper
    include Service

    def initialize(start_date: "2024-01-01", end_date: "2024-12-30")
      @start_date = Date.parse(start_date)
      @end_date = Date.parse(end_date)
    end

    def call
      puts "Starting the bulk scraping process..."

      (@start_date..@end_date).step(7).each do |week_date|
        week_date_str = week_date.strftime("%Y-%m-%d")
        puts "Processing week: #{week_date_str}"

        PlayerRankings::CreateOrUpdatePlayerRankingWeek.new("0-100", week_date_str).fetch
      end

      puts "Finished bulk scraping process."
    end
  end
end
