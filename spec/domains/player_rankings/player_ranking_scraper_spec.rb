require 'rails_helper'

RSpec.describe PlayerRankings::PlayerRankingScraper, type: :service do
  let(:rank_range) { '1-100' }
  let(:date_week) { '2024-11-11' }
  let(:scraper) { described_class.new(rank_range, date_week) }

  describe '#fetch' do
    it 'scrapes valid player rankings without errors' do
      expect {
        scraper.fetch
      }.not_to raise_error
    end

    it 'processes 100 valid rows and logs them' do
      expect {
        scraper.fetch
      }.to output(/Found 100 valid rows./).to_stdout
    end
  end
end
