module TennisPlayers
  class UpdateAllTennisPlayersProfile
    include Service

    def call
      TennisPlayer.where(full_name: nil).find_in_batches(batch_size: 100) do |batch|
        ::TennisPlayers::TennisPlayersBatchJob.perform_later(batch)
      end
    end
  end
end