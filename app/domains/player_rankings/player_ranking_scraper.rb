require "selenium-webdriver"

module PlayerRankings
  class PlayerRankingScraper < ::Scrapers::BaseScraper
    BASE_URL = "https://www.atptour.com"

    def initialize(rank_range, date_week)
      super()
      @rank_range = rank_range
      @date_week = date_week
      @url = "#{BASE_URL}/en/rankings/singles?rankRange=#{rank_range}&dateWeek=#{date_week}"
    end

    def fetch
      puts "Starting the scraping process using Selenium..."

      begin
        @driver.navigate.to(@url)
        sleep(2)
        rows = @driver.find_elements(css: ".mega-table tbody tr").select do |row|
          # Only include rows that have rank and player name
          rank_element = row.find_elements(css: ".rank.bold.heavy.tiny-cell")
          name_element = row.find_elements(css: ".player.bold.heavy.large-cell")

          # Ensure both rank and name elements exist
          rank_element.any? && name_element.any?
        end

        valid_rows = rows.select do |row|
          rank = row.find_element(css: ".rank.bold.heavy.tiny-cell").text.strip.to_i rescue nil
          # Filter by rank range
          rank && rank >= 1 && rank <= 100
        end

        puts "Found #{valid_rows.size} valid rows."

        valid_rows.each_with_index do |row, index|
          puts "Processing row #{index + 1}"
          begin
            rank = row.find_element(css: ".rank.bold.heavy.tiny-cell").text.strip.to_i
            player_name_element = row.find_element(css: ".player.bold.heavy.large-cell ul li.name a")
            full_name = player_name_element.find_element(css: "span").text.strip
            player_link = player_name_element.attribute("href")
            tennis_player_id = extract_player_slug(player_link)

            puts "Rank: #{rank}, Full Name: #{full_name}, Player Link: #{player_link}, Player ID: #{tennis_player_id}"

            PlayerRankings::CreateOrUpdatePlayerRanking.call(
              full_name: full_name,
              tennis_player_slug: tennis_player_id,
              player_url: player_link,
              ranking: rank,
              week_date: date_week
            )

            puts "Processed player: #{full_name} (Rank: #{rank})"
          rescue Selenium::WebDriver::Error::NoSuchElementError => e
            puts "Error parsing row #{index + 1}: #{e.message}"
          end
        end

      ensure
        @driver.quit
      end
    end

    private

    attr_reader :rank_range, :date_week

    def extract_player_slug(player_link)
      return nil unless player_link
      URI(player_link).path.split('/')[3..4].join('/')
    end

    def chrome_options
      options = Selenium::WebDriver::Options.chrome
      options.add_argument("--user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36")
      options.add_argument("--headless")
      options.add_argument("--disable-gpu")
      options.add_argument("--window-size=1080,720")
      options.add_argument("--no-sandbox")
      options.add_argument("--disable-dev-shm-usage")
      options
    end
  end
end
