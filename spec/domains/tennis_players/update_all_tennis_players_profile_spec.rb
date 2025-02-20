# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TennisPlayers::UpdateAllTennisPlayersProfile, type: :service do

  before do
    create(:tennis_player, tennis_player_slug: 'jannik-sinner/s0ag')
    create(:tennis_player, tennis_player_slug: 'richard-gasquet/g628')
  end

  describe '#call' do
    it 'updates all tennis players data without errors' do
      expect {
        described_class.call
      }.not_to raise_error
    end

    it 'updates the data for the player' do
      player_1 = TennisPlayer.find_by(tennis_player_slug: 'jannik-sinner/s0ag')
      player_2 = TennisPlayer.find_by(tennis_player_slug: 'richard-gasquet/g628')

      expect(player_1.full_name).to eq nil
      expect(player_1.height).to eq nil
      expect(player_1.weight).to eq nil
      expect(player_1.playing_style).to eq nil
      expect(player_1.player_url).to eq nil
      expect(player_1.career_highest_ranking).to eq nil
      expect(player_1.career_highest_ranking_date).to eq nil

      expect(player_2.full_name).to eq nil
      expect(player_2.height).to eq nil
      expect(player_2.weight).to eq nil
      expect(player_2.playing_style).to eq nil
      expect(player_2.player_url).to eq nil
      expect(player_2.career_highest_ranking).to eq nil
      expect(player_2.career_highest_ranking_date).to eq nil

      described_class.call

      player_1_updated = TennisPlayer.find_by(tennis_player_slug: 'jannik-sinner/s0ag')
      player_2_updated = TennisPlayer.find_by(tennis_player_slug: 'richard-gasquet/g628')


      expect(player_1_updated.full_name).to eq 'Jannik Sinner'
      expect(player_1_updated.height).to eq 191
      expect(player_1_updated.weight).to eq 77
      expect(player_1_updated.playing_style).to eq 'Right-Handed, Two-Handed Backhand'
      expect(player_1_updated.player_url).to eq 'https://www.atptour.com/en/players/jannik-sinner/s0ag/overview'
      expect(player_1_updated.career_highest_ranking).to eq 1
      expect(player_1_updated.career_highest_ranking_date).to eq Date.new(2024, 06, 10)

      expect(player_2_updated.full_name).to eq 'Richard Gasquet'
      expect(player_2_updated.height).to eq 183
      expect(player_2_updated.weight).to eq 79
      expect(player_2_updated.playing_style).to eq 'Right-Handed, One-Handed Backhand'
      expect(player_2_updated.player_url).to eq 'https://www.atptour.com/en/players/richard-gasquet/g628/overview'
      expect(player_2_updated.career_highest_ranking).to eq 7
      expect(player_2_updated.career_highest_ranking_date).to eq Date.new(2007, 07, 9)
    end
  end
end
