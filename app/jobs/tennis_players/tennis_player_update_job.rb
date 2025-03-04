class TennisPlayers::TennisPlayerUpdateJob < ApplicationJob
  queue_as :default

  def perform(tennis_player_slug)
    puts "⏳ Updating profile for player: #{tennis_player_slug}..."
    ::TennisPlayers::UpdateTennisPlayerProfile.call(tennis_player_slug)
    puts "✅ Successfully updated profile for: #{tennis_player_slug}"
  rescue StandardError => e
    puts "❌ Error updating profile for #{tennis_player_slug}: #{e.message}"
  end
end
