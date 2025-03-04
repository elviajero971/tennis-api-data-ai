require "net/http"
require "json"
require "uri"
require "selenium-webdriver"
require "nokogiri"

module TennisPlayers
  class TennisPlayerProfileFetcher
    BASE_URL = "https://www.atptour.com/en/-/www/players/hero"

    def initialize(tennis_player_slug)
      @tennis_player_slug = tennis_player_slug
      @driver = Selenium::WebDriver.for(:chrome, options: chrome_options)
    end

    def fetch
      data = {}
      TimeTracker::ProcessTimeTracker.track("Fetch player profile for player: #{tennis_player_slug}") do
        player_id = tennis_player_slug.split("/").last
        json_url = "#{BASE_URL}/#{player_id}"
        response = fetch_json_data(json_url)

        if response
          puts "Successfully retrieved player data."
          data = formatted_player_data(response)
        else
          puts "Failed to retrieve player data."
          nil
        end
      end

      data
    end

    private

    attr_reader :tennis_player_slug

    ### **Step 1: Fetch JSON Data**
    def fetch_json_data(url)
      begin
        @driver.navigate.to(url)

        html = @driver.page_source

        doc = Nokogiri::HTML(html)

        json_data = doc.css("pre").text

        JSON.parse(json_data)
      rescue StandardError => e
        puts "Error during request: #{e.message}"
        nil
      ensure
        @driver.quit
      end
    end

    ### **Step 2: Parse JSON and Extract Data**
    def formatted_player_data(data)
      {
        full_name: "#{data['FirstName']} #{data['LastName']}",
        date_of_birth: data["BirthDate"],
        age: data["Age"],
        height_in_cm: data["HeightCm"],
        weight_in_kg: data["WeightKg"],
        nationality: data["Nationality"],
        place_of_birth: data["BirthCity"],
        play_hand: data.dig('PlayHand', 'Description'),
        back_hand: data.dig('BackHand', 'Description'),
        career_highest_ranking_singles: data["SglHiRank"],
        career_highest_ranking_date_singles: data["SglHiRankDate"],
        nb_career_titles_singles: data["SglCareerTitles"],
        nb_career_wins_singles: data["SglCareerWon"],
        nb_career_losses_singles: data["SglCareerLost"],
        nb_career_matches_singles: nb_career_matches(data["SglCareerWon"], data["SglCareerLost"]),
        career_highest_ranking_doubles: data["DblHiRank"],
        career_highest_ranking_date_doubles: data["DblHiRankDate"],
        nb_career_titles_doubles: data["DblCareerTitles"],
        nb_career_wins_doubles: data["DblCareerWon"],
        nb_career_losses_doubles: data["DblCareerLost"],
        nb_career_matches_doubles: nb_career_matches(data["DblCareerWon"], data["DblCareerLost"]),
        active_player: data.dig('Active', 'Description') == "Active",
        current_coach: data["Coach"],
        career_prize_money: format_prize_money(data["CareerPrizeFormatted"]),
        player_url: "https://www.atptour.com#{data['ScRelativeUrlPlayerProfile']}",
      }
    end

    def nb_career_matches(wins, losses)
      wins.to_i + losses.to_i
    end

    def format_prize_money(prize_money)
      prize_money.gsub(/[^0-9]/, "").to_i
    end

    def chrome_options
      options = Selenium::WebDriver::Chrome::Options.new
      options.add_argument("--user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36")
      options.add_argument("--headless")
      options.add_argument("--disable-gpu")
      options.add_argument("--window-size=1920,1080")
      options.add_argument("--no-sandbox")
      options.add_argument("--disable-dev-shm-usage")
      options
    end
  end
end


