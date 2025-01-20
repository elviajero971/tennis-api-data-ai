module TennisPlayers
  class UpdateAllTennisPlayersData
    include Service

    def call
      TennisPlayer.find_each do |player|
        scraper = TennisPlayers::AtpPlayerProfileScraper.new(player.tennis_player_slug)
        player_data = scraper.fetch_player_data

        if player_data
          player.update(player_data)
          puts "Successfully updated #{player.full_name}."
        else
          puts "Failed to update #{player.full_name}."
        end
      end
    end
  end
end
