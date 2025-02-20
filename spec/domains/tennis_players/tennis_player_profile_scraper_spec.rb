# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TennisPlayers::TennisPlayerProfileScraper, type: :service do
  let(:tennis_player_slug) { 'jannik-sinner/s0ag' }
  let(:scraper) { described_class.new(tennis_player_slug) }

  describe '#fetch' do
    it 'scrapes valid player profile without errors' do
      expect {
        scraper.fetch
      }.not_to raise_error
    end

    it 'returns correct data for the player' do
      player_data = scraper.fetch

      expected_player_data = {
        full_name: 'Jannik Sinner',
        height: 191,
        weight: 77,
        playing_style: 'Right-Handed, Two-Handed Backhand',
        player_url: 'https://www.atptour.com/en/players/jannik-sinner/s0ag/overview',
        career_highest_ranking: 1,
        career_highest_ranking_date: Date.new(2024, 6, 10),
        date_of_birth: Date.new(2001, 8, 16)
      }

      expect(player_data).to include(expected_player_data)
    end
  end
end
