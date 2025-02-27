module TennisPlayers
  class UpdateAllTennisPlayersProfile
    include Service

    def call
      TennisPlayer.find_in_batches(batch_size: 100) do |batch|
        TennisPlayersBatchJob.perform_later(batch)
      end
    end
  end
end