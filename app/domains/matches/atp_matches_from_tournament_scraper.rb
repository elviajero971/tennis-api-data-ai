# app/domains/tournaments/tournament_scraper.rb

module Matches
  class AtpMatchesFromTournamentScraper < ::Scrapers::BaseScraper
    def initialize(slug:, reference:, year:)
      super()
      @year = year
      @slug = slug
      @reference = reference
    end

    def fetch
      @driver.navigate.to("#{BASE_URL}/en/scores/archive/#{slug}/#{reference}/#{year}/results")
      # sleep(2)

      html = @driver.find_element(css: "div.atp_accordion-items").attribute("outerHTML")

      parse_html(html)
    rescue StandardError => e
      puts "Error scraping tournament matches: #{e.message}"
      []
    ensure
      quit_driver
    end

    private

    attr_reader :year, :slug, :reference

    def parse_html(html)
      # Parse the HTML using Nokogiri
      doc = Nokogiri::HTML(html)

      # Extract and process match data
      tournament_matches_data = []
      doc.css("div.atp_accordion-item").each do |round|
        round_matches = extract_round_matches_data(round)
        tournament_matches_data << round_matches
      end
      tournament_matches_data.flatten
    end

    def extract_round_matches_data(round)
      round.css("div.match-group div.match-group-content div.match").map do |match|
        {
          year_of_tournament: year,
          tournament_slug: slug,
          tournament_reference: reference,
          round: extract_round(match),
          duration: extract_duration(match),
          player_1_slug: extract_player_1_slug(match),
          player_2_slug: extract_player_2_slug(match),
          player_winner_slug: extract_player_winner_slug(match),
          match_score: extract_match_score(match)
        }
      end
    end

    def extract_round(match)
      round_text = match.css("div.match-header span").first&.text
      # split on the last dash to get the round
      # Semi-finals - Centre Court => Semi-finals
      round_text = round_text.split(" - ").first

      if round_text.present?
        case round_text
        when "Finals -"
          "final"
        when "Semi-Finals -"
          "semi_final"
        when "Quarter-finals -"
          "quarter_final"
        when "Quarter-finals -"
          "quarter_final"
        when "Round of 16 -"
          "round_of_16"
        when "Round of 32 -"
          "round_of_32"
        when "Round of 64 -"
          "round_of_64"
        when "Round of 128 -"
          "round_of_128"
        when "1st Round Qualifying"
          "first_round_qualifying"
        when "2nd Round Qualifying"
          "second_round_qualifying"
        when "3rd Round Qualifying"
          "third_round_qualifying"
        when "Round Robin -"
          "round_robin"
        else
          round_text.downcase.gsub(" ", "_")
        end
      end
    end

    def extract_duration(match)
      duration_string = match.css("div.match-header span").last&.text&.strip
      duration_string
      if duration_string.present?
        hours, minutes = duration_string.split(":").map(&:to_i)
        hours * 60 + minutes
      else
        0
      end
    end

    def extract_player_1_slug(match)
      begin
        player_1_info = match.css("div.match-content div.match-stats div.stats-item").first
        data = player_1_info.css("div.player-info div.name a").attribute("href").value
        data.split("/en/players/").last.split("/overview").first
      rescue StandardError => e
        puts "Error extracting player 1 profile: #{e.message}"
        nil
      end
    end

    def extract_player_2_slug(match)
      begin
        player_2_info = match.css("div.match-content div.match-stats div.stats-item").last
        data = player_2_info.css("div.player-info div.name a").attribute("href").value
        data.split("/en/players/").last.split("/overview").first
      rescue StandardError => e
        puts "Error extracting player 2 profile: #{e.message}"
        nil
      end
    end

    def extract_player_winner_slug(match)
      match.css("div.match-content div.match-stats div.stats-item").first.css("div.winner").present? ? extract_player_1_slug(match) : extract_player_2_slug(match)
    end

    def extract_match_score(match)
      scores = match.css("div.match-content div.match-stats div.stats-item div.scores")
      score_player_1 = scores.first.css("div.score-item")
      score_player_2 = scores.last.css("div.score-item")

      compute_match_score(score_player_1.text, score_player_2.text)
    end

    def compute_match_score(score_player_1, score_player_2)
      scores_player_1 = score_player_1.split
      scores_player_2 = score_player_2.split

      scores_player_1.zip(scores_player_2).map { |s1, s2| "#{s1}/#{s2}" }.join(" ")
    end
  end
end
