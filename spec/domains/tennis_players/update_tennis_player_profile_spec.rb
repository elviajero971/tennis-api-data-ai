# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TennisPlayers::UpdateTennisPlayerProfile, type: :service do

  before do
    create(:tennis_player, tennis_player_slug: 'richard-gasquet/g628')
  end

  describe '#call' do
    it 'updates all tennis players data without errors' do
      expect {
        described_class.call('richard-gasquet/g628')
      }.not_to raise_error
    end

    it 'updates the data for the player' do
      player = TennisPlayer.find_by(tennis_player_slug: 'richard-gasquet/g628')

      expect(player.full_name).to eq nil
      expect(player.height).to eq nil
      expect(player.weight).to eq nil
      expect(player.playing_style).to eq nil
      expect(player.player_url).to eq nil
      expect(player.career_highest_ranking).to eq nil
      expect(player.career_highest_ranking_date).to eq nil

      described_class.call('richard-gasquet/g628')

      player_updated = TennisPlayer.find_by(tennis_player_slug: 'richard-gasquet/g628')

      expect(player_updated.full_name).to eq 'Richard Gasquet'
      expect(player_updated.height).to eq 183
      expect(player_updated.weight).to eq 79
      expect(player_updated.playing_style).to eq 'Right-Handed, One-Handed Backhand'
      expect(player_updated.player_url).to eq 'https://www.atptour.com/en/players/richard-gasquet/g628/overview'
      expect(player_updated.career_highest_ranking).to eq 7
      expect(player_updated.career_highest_ranking_date).to eq Date.new(2007, 07, 9)
    end
  end
end
