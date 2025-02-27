module TennisPlayers
  class UpdateTennisPlayerProfile
    include Service

    def initialize(player_slug)
      @player_slug = player_slug
    end

    def call
      TimeTracker::ProcessTimeTracker.track("Update player profile for player: #{player_slug}") do
        scraper_data = TennisPlayers::TennisPlayerProfileFetcher.new(player_slug).fetch

        player = TennisPlayer.find_by(tennis_player_slug: player_slug)

        if scraper_data
          player.update!(scraper_data)
        else
          puts "Failed to update #{player.tennis_player_slug} because of missing data while scraping."
        end
      end
    end

    private

    attr_reader :player_slug
  end
end
