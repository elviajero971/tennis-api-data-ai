require "selenium-webdriver"
require "nokogiri"

module TennisPlayers
  class TennisPlayerProfileScraper < ::Scrapers::BaseScraper

    def initialize(tennis_player_slug)
      super()
      @tennis_player_slug = tennis_player_slug
    end

    def fetch
      datas = {}
      TimeTracker::ProcessTimeTracker.track("Scrap player profile for player: #{tennis_player_slug}") do
        begin
          @driver.navigate.to(player_url)

          dismiss_cookie_banner

          # print html elements
          wait = Selenium::WebDriver::Wait.new(timeout: 10)
          singles_button = wait.until {
            @driver.find_element(css: "div.player_profile div.atp_player-stats div.stats-type div.tab-switcher ul li:nth-of-type(1) a")
          }

          # Ensure the element is interactable before clicking
          if singles_button.displayed? && singles_button.enabled?
            puts "Clicking on the Singles button..."
            singles_button.click
          else
            puts "Singles button is not interactable."
            return nil
          end

          html = @driver.page_source
          doc = Nokogiri::HTML(html)

          datas = {
            full_name: extract_full_name(doc),
            date_of_birth: extract_date_of_birth(doc),
            age: calculate_age(doc),
            height_in_cm: extract_height(doc),
            weight_in_kg: extract_weight(doc),
            place_of_birth: extract_place_of_birth(doc),
            play_hand: extract_playing_style(doc),
            back_hand: extract_playing_style(doc),
            career_highest_ranking_singles: extract_career_highest_ranking(doc),
            career_highest_ranking_date_singles: extract_career_highest_ranking_date(doc),
            nb_career_titles_singles: extract_nb_career_titles(doc),
            nb_career_wins_singles: extract_nb_career_wins(doc),
            nb_career_losses_singles: extract_nb_career_losses(doc),
            nb_career_matches_singles: extract_nb_career_wins(doc).to_i + extract_nb_career_losses(doc).to_i,
            current_coach: extract_coach(doc),
            career_prize_money: extract_career_prize_money(doc),
            player_url: player_url
          }
        rescue StandardError => e
          puts "An error occurred: #{e.message}"
          nil
        ensure
          @driver.quit
        end
      end

      datas
    end

    private

    attr_reader :tennis_player_slug

    def dismiss_cookie_banner
      begin
        wait = Selenium::WebDriver::Wait.new(timeout: 10)

        overlay = @driver.find_elements(css: "div.onetrust-pc-dark-filter").first
        if overlay
          @driver.execute_script("arguments[0].remove();", overlay)
          # sleep(0.5) # Give time for UI to update
        end

        cookie_button = wait.until {
          btn = @driver.find_element(css: "button#onetrust-accept-btn-handler")
          btn if btn.displayed? && btn.enabled?
        }
        # Use JavaScript to click in case of interception error
        @driver.execute_script("arguments[0].click();", cookie_button)
        # sleep(1)
      rescue Selenium::WebDriver::Error::NoSuchElementError
        puts "No cookie consent popup found, continuing..."
      rescue Selenium::WebDriver::Error::ElementClickInterceptedError
        puts "Element click intercepted, retrying with JavaScript..."
        @driver.execute_script("arguments[0].click();", cookie_button)
      rescue Selenium::WebDriver::Error::TimeoutError
        puts "Timed out waiting for cookie banner, skipping..."
      end
    end

    def player_url
      "#{BASE_URL}/en/players/#{tennis_player_slug}/overview"
    end

    def extract_full_name(doc)
      doc.css("div.atp_player_content div.player_profile div.player_name span").text.strip
    rescue
      nil
    end

    def extract_nb_career_wins_and_losses(doc)
      doc.css("div.atp_player_content div.player_profile div.atp_player-stats div.stats-content div.player-stats-details:nth-of-type(2) div.wins").text.strip
    rescue
      nil
    end

    def extract_nb_career_losses(doc)
      career_wins_and_losses = extract_nb_career_wins_and_losses(doc)
      career_losses = career_wins_and_losses.split("\n").first.split(" - ").last.strip
      career_losses.to_i
    rescue
      nil
    end

    def extract_nb_career_wins(doc)
      career_wins_and_losses = extract_nb_career_wins_and_losses(doc)
      career_wins = career_wins_and_losses.split("\n").first.split(" - ").first.strip
      career_wins.to_i
    rescue
      nil
    end

    def extract_nb_career_titles(doc)
      career_titles = doc.css("div.atp_player_content div.player_profile div.atp_player-stats div.stats-content div.player-stats-details:nth-of-type(2) div.titles").text.strip
      career_titles = career_titles.split("\n").first.strip
      career_titles.to_i
    rescue
      nil
    end

    def extract_career_prize_money(doc)
      prize_money = doc.css("div.atp_player_content div.player_profile div.atp_player-stats div.stats-content div.player-stats-details:nth-of-type(2) div.prize_money").text.strip
      prize_money.gsub(/[$,]/, "").to_i
    rescue
      nil
    end

    def extract_playing_style(doc)
      doc.css("div.atp_player-personaldetails div.personal_details div.pd_content ul.pd_right li:nth-of-type(3) span:nth-of-type(2)").text.strip
    rescue
      nil
    end

    def extract_weight(doc)
      weight = doc.css("div.atp_player-personaldetails div.personal_details div.pd_content ul.pd_left li:nth-of-type(2) span:nth-of-type(2)").text.strip
      weight.match(/\((.*?)kg\)/)[1].to_i
    rescue
      nil
    end

    def extract_height(doc)
      height = doc.css("div.atp_player-personaldetails div.personal_details div.pd_content ul.pd_left li:nth-of-type(3) span:nth-of-type(2)").text.strip
      height.match(/\((.*?)cm\)/)[1].to_i
    rescue
      nil
    end

    def extract_date_of_birth(doc)
      raw_data = doc.css("div.atp_player-personaldetails div.personal_details div.pd_content ul.pd_left li:nth-of-type(1) span:nth-of-type(2)").text.strip
      if raw_data =~ /\d{4}\/\d{2}\/\d{2}/
        Date.strptime(raw_data.match(/\d{4}\/\d{2}\/\d{2}/)[0], "%Y/%m/%d")
      else
        raise ArgumentError, "Invalid input format. Unable to parse date from: #{raw_data}"
      end
    rescue
      nil
    end

    def calculate_age(doc)
      today = Date.today
      birth_date = extract_date_of_birth(doc)
      return nil unless birth_date

      age = today.year - birth_date.year
      age -= 1 if today < birth_date + age.years
      age
    rescue
      nil
    end

    def extract_career_highest_ranking_raw(doc)
      doc.css("div.atp_player-stats div.stats-content div.player-stats-details:nth-of-type(2) div.stat").text.strip
    rescue
      nil
    end

    def extract_career_highest_ranking(doc)
      extract_career_highest_ranking_raw(doc).split("\n").first.strip.to_i
    rescue
      nil
    end

    def extract_career_highest_ranking_date(doc)
      ranking_date = extract_career_highest_ranking_raw(doc).split("\n").last.strip
      ranking_date.match(/\((.*?)\)/)[1].to_date
    rescue
      nil
    end

    def extract_place_of_birth(doc)
      doc.css("div.atp_player-personaldetails div.personal_details div.pd_content ul.pd_right li:nth-of-type(2) span:nth-of-type(2)").text.strip
    rescue
      nil
    end

    def extract_coach(doc)
      doc.css("div.atp_player-personaldetails div.personal_details div.pd_content ul.pd_right li:nth-of-type(4) span:nth-of-type(2)").text.strip
    rescue
      nil
    end
  end
end
