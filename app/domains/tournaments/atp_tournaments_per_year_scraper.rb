# app/domains/tournaments/tournament_scraper.rb

module Tournaments
  class AtpTournamentsPerYearScraper < ::Scrapers::BaseScraper
    ARCHIVE_ATP_TOURNAMENT_URL = "https://www.atptour.com/en/scores/results-archive?year="

    def initialize(year)
      super()
      @year = year
    end

    def fetch_tournaments_year_data
      @driver.navigate.to("#{ARCHIVE_ATP_TOURNAMENT_URL}#{@year}")
      sleep(2)

      tournaments_year = []

      @driver.find_elements(css: "ul.events").each do |ul|
        tournaments_year << extract_tournament_year_data(ul)
      end

      puts "tournaments year data: #{tournaments_year}"

      tournaments_year
    rescue StandardError => e
      puts "Error scraping tournaments_year: #{e.message}"
      []
    ensure
      quit_driver
    end

    private

    def extract_tournament_year_data(ul)
      {
        tournament_year: @year,
        tournament_reference: extract_tournament_reference(ul),
        tournament_slug: extract_tournament_slug(ul),
        tournament_type: extract_type(ul),
        tournament_category: "atp",
        tournament_name: extract_tournament_name(ul),
        tournament_winner_single_tennis_player_slug: extract_player_slug(ul)
      }
    rescue Selenium::WebDriver::Error::NoSuchElementError
      nil
    end

    def extract_tournament_name(ul)
      clean_name(ul.find_element(css: ".tournament__profile").text.strip)
    rescue Selenium::WebDriver::Error::NoSuchElementError
      nil
    end

    def clean_name(name)
      name.split(" | ").first
    end

    def extract_tournament_data(ul)
      url = ul.find_element(css: ".tournament__profile").attribute("href")
      url.split("/en/tournaments/").last.split("/overview").first
    rescue Selenium::WebDriver::Error::NoSuchElementError
      nil
    end

    def extract_tournament_slug(ul)
      return nil if extract_tournament_data(ul).nil?

      data = extract_tournament_data(ul)
      data.split("/").first
    rescue Selenium::WebDriver::Error::NoSuchElementError
      nil
    end

    def extract_tournament_reference(ul)
      return nil if extract_tournament_data(ul).nil?

      data = extract_tournament_data(ul)

      data.split("/").last
    rescue Selenium::WebDriver::Error::NoSuchElementError
      nil
    end

    def extract_type(ul)
      img_src = ul.find_element(css: ".event-badge_container img").attribute("src")
      tournament_type = img_src.split("/").last.split("_").last.split(".").first.gsub("stamps", "").gsub("_", " ")

      if tournament_type.present?
        tournament_type
      else
        "Unknown"
      end
    rescue Selenium::WebDriver::Error::NoSuchElementError
      "Unknown"
    end

    def extract_player_slug(element)
      player_link = element.find_element(css: "dd a").attribute("href")
      player_link.split("/en/players/").last.split("/overview").first
    rescue Selenium::WebDriver::Error::NoSuchElementError
      nil
    end
  end
end
