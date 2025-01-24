require "selenium-webdriver"

module PlayerRankings
  class PlayerRankingWeekScraper < ::Scrapers::BaseScraper
    def initialize(rank_range, date_week)
      super()
      @rank_range = rank_range
      @date_week = date_week
      @url = "#{BASE_URL}/en/rankings/singles?rankRange=#{rank_range}&dateWeek=#{date_week}"
    end

    def fetch
      puts "Starting the scraping process using Selenium..."

      player_data = []

      begin
        @driver.navigate.to(@url)
        rows = @driver.find_elements(css: ".mega-table tbody tr").select do |row|
          rank_element = row.find_elements(css: ".rank.bold.heavy.tiny-cell")
          name_element = row.find_elements(css: ".player.bold.heavy.large-cell")
          rank_element.any? && name_element.any?
        end

        valid_rows = rows.select do |row|
          rank = row.find_element(css: ".rank.bold.heavy.tiny-cell").text.strip.to_i rescue nil
          rank && rank >= 1 && rank <= @rank_range.split('-').last.to_i
        end

        puts "Found #{valid_rows.size} valid rows."

        valid_rows.each_with_index do |row, index|
          begin
            rank = row.find_element(css: ".rank.bold.heavy.tiny-cell").text.strip.to_i
            player_name_element = row.find_element(css: ".player.bold.heavy.large-cell ul li.name a")
            full_name = player_name_element.find_element(css: "span").text.strip
            player_link = player_name_element.attribute("href")
            tennis_player_slug = extract_player_slug(player_link)
            player_url = "#{BASE_URL}/en/players/#{tennis_player_slug}/overview"

            player_data << {
              full_name: full_name,
              tennis_player_slug: tennis_player_slug,
              player_url: player_url,
              ranking: rank,
              week_date: @date_week
            }
          rescue Selenium::WebDriver::Error::NoSuchElementError => e
            puts "Error processing row #{index + 1}: #{e.message}"
          end
        end
      ensure
        @driver.quit
      end

      player_data
    end

    private

    def extract_player_slug(player_link)
      return nil unless player_link
      slug = URI(player_link).path.split('/')[3..4].join('/')
      # remove all spaces and special characters from the slug except / and -
      slug.gsub(/[^0-9a-z\/-]/i, '')
    end
  end
end
