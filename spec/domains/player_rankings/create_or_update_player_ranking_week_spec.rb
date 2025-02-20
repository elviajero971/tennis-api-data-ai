# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PlayerRankings::CreateOrUpdatePlayerRankingWeek, type: :service do
  let(:rank_range) { '1-100' }
  let(:date_week) { '2024-11-11' }
  let(:service) { described_class.new(rank_range, date_week) }

  describe '#call' do
    it 'creates or updates player rankings without errors' do
      expect {
        service.call
      }.not_to raise_error
    end

    it 'creates or updates player rankings for the top 5 ranked players' do
      expect(TennisPlayer.all).to be_empty
      expect(PlayerRanking.all).to be_empty

      service.call

      player_1 = TennisPlayer.find_by(tennis_player_slug: 'jannik-sinner/s0ag')
      player_2 = TennisPlayer.find_by(tennis_player_slug: 'alexander-zverev/z355')
      player_3 = TennisPlayer.find_by(tennis_player_slug: 'carlos-alcaraz/a0e2')
      player_4 = TennisPlayer.find_by(tennis_player_slug: 'daniil-medvedev/mm58')
      player_5 = TennisPlayer.find_by(tennis_player_slug: 'taylor-fritz/fb98')

      ranking_1 = PlayerRanking.find_by(tennis_player: player_1, week_date: date_week)
      ranking_2 = PlayerRanking.find_by(tennis_player: player_2, week_date: date_week)
      ranking_3 = PlayerRanking.find_by(tennis_player: player_3, week_date: date_week)
      ranking_4 = PlayerRanking.find_by(tennis_player: player_4, week_date: date_week)
      ranking_5 = PlayerRanking.find_by(tennis_player: player_5, week_date: date_week)


      expect(player_1).to be_present
      expect(player_2).to be_present
      expect(player_3).to be_present
      expect(player_4).to be_present
      expect(player_5).to be_present

      expect(ranking_1).to be_present
      expect(ranking_2).to be_present
      expect(ranking_3).to be_present
      expect(ranking_4).to be_present
      expect(ranking_5).to be_present
    end
  end
end
