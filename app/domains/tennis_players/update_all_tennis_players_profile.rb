module TennisPlayers
  class UpdateAllTennisPlayersProfile
    include Service

    def call
      TimeTracker::ProcessTimeTracker.track("Update all tennis players data") do
        TennisPlayer.find_in_batches(batch_size: 100) do |batch|
          Parallel.each(batch, in_threads: Parallel.processor_count) do |player|
            TennisPlayers::UpdateTennisPlayerProfile.call(player.tennis_player_slug)
          end
        end
      end
    end
  end
end
