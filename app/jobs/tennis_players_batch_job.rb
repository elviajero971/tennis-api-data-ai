class TennisPlayersBatchJob < ApplicationJob
  queue_as :default

  def perform(batch)
    batch.each do |player|
      TennisPlayerUpdateJob.perform_later(player.tennis_player_slug)
    end
  rescue StandardError => e
    puts "❌ Error processing batch: #{e.message}"
  end
end