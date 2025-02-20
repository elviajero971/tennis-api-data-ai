require 'rails_helper'

RSpec.describe PlayerRankings::PlayerRankingWeekScraper, type: :service do
  let(:rank_range) { '1-100' }
  let(:date_week) { '2024-11-11' }
  let(:scraper) { described_class.new(rank_range, date_week) }

  describe '#fetch' do
    it 'scrapes player rankings without errors' do
      expect { scraper.fetch }.not_to raise_error
    end

    it 'returns valid player data for top 100' do
      player_data = scraper.fetch

      expect(player_data).to all(include(:ranking, :tennis_player_slug, :week_date))
      expect(player_data.size).to eq(100)
    end

    it 'returns correct data for the top 5 ranked players' do
      top_5_ranked_players_data = scraper.fetch.first(5)

      expected_top_5_ranked_players_data = [
        {
          ranking: 1,
          tennis_player_slug: 'jannik-sinner/s0ag',
          week_date: '2024-11-11'
        },
        {
          ranking: 2,
          tennis_player_slug: 'alexander-zverev/z355',
          week_date: '2024-11-11'
        },
        {
          ranking: 3,
          tennis_player_slug: 'carlos-alcaraz/a0e2',
          week_date: '2024-11-11'
        },
        {
          ranking: 4,
          tennis_player_slug: 'daniil-medvedev/mm58',
          week_date: '2024-11-11'
        },
        {
          ranking: 5,
          tennis_player_slug: 'taylor-fritz/fb98',
          week_date: '2024-11-11'
        }
      ]

      expect(top_5_ranked_players_data).to eq(expected_top_5_ranked_players_data)
    end
  end
end
