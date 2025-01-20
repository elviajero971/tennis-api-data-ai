require "selenium-webdriver"

module TennisPlayers
  class AtpPlayerProfileScraper < ::Scrapers::BaseScraper

    def initialize(tennis_player_slug)
      super()
      @tennis_player_slug = tennis_player_slug
    end

    def fetch_player_data
      begin
        @driver.navigate.to(player_url)

        data = {
          full_name: extract_full_name,
          age: calculate_age,
          date_of_birth: extract_date_of_birth,
          weight: extract_weight,
          height: extract_height,
          playing_style: extract_playing_style,
          player_url: player_url,
          career_highest_ranking: extract_career_highest_ranking,
          career_highest_ranking_date: extract_career_highest_ranking_date,
          place_of_birth: extract_place_of_birth,
          current_coach: extract_coach,
          career_prize_money: extract_career_prize_money,
          nb_career_titles: extract_nb_career_titles,
          nb_career_wins: extract_nb_career_wins,
          nb_career_losses: extract_nb_career_losses,
          nb_career_matches: extract_nb_career_wins.to_i + extract_nb_career_losses.to_i
        }

        puts "Player data: #{data}"
        data
      rescue StandardError => e
        puts "An error occurred: #{e.message}"
        nil
      ensure
        @driver.quit
      end
    end

    private

    attr_reader :tennis_player_slug

    def player_url
      "https://www.atptour.com/en/players/#{tennis_player_slug}/overview"
    end

    def extract_full_name
      @driver.find_element(css: "div.atp_player_content div.player_profile div.player_name span").text.strip
    rescue Selenium::WebDriver::Error::NoSuchElementError
      nil
    end

    def extract_nb_career_wins_and_losses
      @driver.find_element(css: "div.atp_player_content div.player_profile div.atp_player-stats div.stats-content div.player-stats-details:nth-of-type(2) div.wins").text.strip
    rescue Selenium::WebDriver::Error::NoSuchElementError
      nil
    end

    def extract_nb_career_losses
      career_wins_and_losses = extract_nb_career_wins_and_losses
      career_losses = career_wins_and_losses.split("\n").first.split(" - ").last.strip
      career_losses.to_i
    end

    def extract_nb_career_wins
      career_wins_and_losses = extract_nb_career_wins_and_losses
      career_wins = career_wins_and_losses.split("\n").first.split(" - ").first.strip
      career_wins.to_i
    end

    def extract_nb_career_titles
      career_titles = @driver.find_element(css: "div.atp_player_content div.player_profile div.atp_player-stats div.stats-content div.player-stats-details:nth-of-type(2) div.titles").text.strip
      career_titles = career_titles.split("\n").first.strip
      career_titles.to_i
    rescue Selenium::WebDriver::Error::NoSuchElementError
      nil
    end

    def extract_career_prize_money
      prize_money = @driver.find_element(css: "div.atp_player_content div.player_profile div.atp_player-stats div.stats-content div.player-stats-details:nth-of-type(2) div.prize_money").text.strip
      prize_money.gsub(/[$,]/, "").to_i
    rescue Selenium::WebDriver::Error::NoSuchElementError
      nil
    end

    def extract_playing_style
      @driver.find_element(css: "div.atp_player-personaldetails div.personal_details div.pd_content ul.pd_right li:nth-of-type(3) span:nth-of-type(2)").text.strip
    rescue Selenium::WebDriver::Error::NoSuchElementError
      nil
    end

    def extract_weight
      weight = @driver.find_element(css: "div.atp_player-personaldetails div.personal_details div.pd_content ul.pd_left li:nth-of-type(2) span:nth-of-type(2)").text.strip
      weight.match(/\((.*?)kg\)/)[1].to_i
    rescue Selenium::WebDriver::Error::NoSuchElementError
      nil
    end


    def extract_height
      height = @driver.find_element(css: "div.atp_player-personaldetails div.personal_details div.pd_content ul.pd_left li:nth-of-type(3) span:nth-of-type(2)").text.strip
      height.match(/\((.*?)cm\)/)[1].to_i
    rescue Selenium::WebDriver::Error::NoSuchElementError
      nil
    end

    def extract_date_of_birth
      raw_data = @driver.find_element(css: "div.atp_player-personaldetails div.personal_details div.pd_content ul.pd_left li:nth-of-type(1) span:nth-of-type(2)").text.strip
      if raw_data =~ /\d{4}\/\d{2}\/\d{2}/
        Date.strptime(raw_data.match(/\d{4}\/\d{2}\/\d{2}/)[0], "%Y/%m/%d")
      else
        raise ArgumentError, "Invalid input format. Unable to parse date from: #{raw_data}"
      end
    rescue Selenium::WebDriver::Error::NoSuchElementError
      nil
    end

    def calculate_age
      today = Date.today
      age = today.year - extract_date_of_birth.year
      age -= 1 if today < extract_date_of_birth + age.years
      age
    end

    def extract_career_highest_ranking_raw
      @driver.find_element(css: "div.atp_player-stats div.stats-content div.player-stats-details:nth-of-type(2) div.stat").text.strip
    rescue Selenium::WebDriver::Error::NoSuchElementError
      nil
    end

    def extract_career_highest_ranking
      extract_career_highest_ranking_raw.split("\n").first.strip.to_i
    rescue Selenium::WebDriver::Error::NoSuchElementError
      nil
    end

    def extract_career_highest_ranking_date
      ranking_date = extract_career_highest_ranking_raw.split("\n").last.strip
      ranking_date.match(/\((.*?)\)/)[1].to_date
    rescue Selenium::WebDriver::Error::NoSuchElementError
      nil
    end


    def extract_place_of_birth
      @driver.find_element(css: "div.atp_player-personaldetails div.personal_details div.pd_content ul.pd_right li:nth-of-type(2) span:nth-of-type(2)").text.strip
    rescue Selenium::WebDriver::Error::NoSuchElementError
      nil
    end

    def extract_coach
      @driver.find_element(css: "div.atp_player-personaldetails div.personal_details div.pd_content ul.pd_right li:nth-of-type(4) span:nth-of-type(2)").text.strip
    rescue Selenium::WebDriver::Error::NoSuchElement
      nil
    end

    def chrome_options
      options = Selenium::WebDriver::Chrome::Options.new
      options.add_argument("--user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36")
      options.add_argument("--headless") # Run in headless mode
      options.add_argument("--disable-gpu")
      options.add_argument("--window-size=1920,1080")
      options.add_argument("--no-sandbox")
      options.add_argument("--disable-dev-shm-usage")
      options
    end
  end
end




