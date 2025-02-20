module TennisPlayers
  class UpdateTennisPlayerProfile
    include Service

    def initialize(player_slug)
      @player_slug = player_slug
    end

    def call
      TimeTracker::ProcessTimeTracker.track("Update player profile for player: #{player_slug}") do
        scraper_data = TennisPlayers::TennisPlayerProfileScraper.new(player_slug).fetch

        puts "Player data: #{scraper_data}"
        if scraper_data && scraper_data[:full_name] == "" && scraper_data[:age].nil? && scraper_data[:height].nil? && scraper_data[:weight].nil? && scraper_data[:career_highest_ranking].nil?
          puts "Failed to update #{scraper_data[:tennis_player_slug]}."
        end

        player = TennisPlayer.find_by(tennis_player_slug: player_slug)

        if scraper_data
          player.update(scraper_data)
        else
          puts "Failed to update #{player.tennis_player_slug}."
        end
      end
    end

    private

    attr_reader :player_slug
  end
end
