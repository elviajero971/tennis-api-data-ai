module TennisPlayers
  class UpdateAllTennisPlayersData
    include Service

    def call
      TimeTracker::ProcessTimeTracker.track("Update all tennis players data") do
        TennisPlayer.find_in_batches(batch_size: 100) do |batch|
          Parallel.each(batch, in_threads: Parallel.processor_count) do |player|
            begin
              scraper = TennisPlayers::AtpPlayerProfileScraper.new(player.tennis_player_slug)
              player_data = scraper.fetch_player_data

              if player_data
                player.update(player_data)
              else
                puts "Failed to update #{player.full_name}."
              end
            rescue StandardError => e
              puts "Error updating player #{player.full_name}: #{e.message}"
            end
          end
        end
      end
    end
  end
end
