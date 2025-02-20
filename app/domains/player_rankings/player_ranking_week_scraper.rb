require "selenium-webdriver"
require "nokogiri"

module PlayerRankings
  class PlayerRankingWeekScraper < ::Scrapers::BaseScraper
    def initialize(rank_range, date_week)
      super()
      @rank_range = rank_range
      @date_week = date_week
      @url = "#{BASE_URL}/en/rankings/singles?rankRange=#{rank_range}&dateWeek=#{date_week}"
    end

    def fetch
      player_data = []

      TimeTracker::ProcessTimeTracker.track("Scraping player rankings for #{@date_week}") do
        puts "Starting the scraping process using Selenium for initial load..."

        begin
          @driver.navigate.to(@url)

          page_source = @driver.page_source
          doc = Nokogiri::HTML(page_source)

          # return empty array if tbody is empty
          return player_data if doc.css("table.mega-table.desktop-table tbody tr").empty?

          rows = doc.css("table.mega-table.desktop-table tbody tr")

          rows.each_with_index do |row, index|
            begin
              rank = row.at_css(".rank.bold.heavy.tiny-cell")&.text&.strip&.to_i
              player_name_element = row.at_css(".player.bold.heavy.large-cell ul li.name a")
              player_link = player_name_element&.[]("href")
              tennis_player_slug = extract_player_slug(player_link)

              next if rank.nil? || rank < 1 || rank > @rank_range.split("-").last.to_i || tennis_player_slug.nil?

              player_data << {
                tennis_player_slug: tennis_player_slug,
                ranking: rank,
                week_date: @date_week
              }
            rescue StandardError => e
              puts "Error processing row #{index + 1}: #{e.message}"
            end
          end
        ensure
          @driver.quit
        end
      end
      player_data
    end

    private

    def extract_player_slug(player_link)
      return nil unless player_link
      slug = URI(player_link).path.split('/')[3..4].join('/')
      slug.gsub(/[^0-9a-z\/-]/i, '')
    end
  end
end
