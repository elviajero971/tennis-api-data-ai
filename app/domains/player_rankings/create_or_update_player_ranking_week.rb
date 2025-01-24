module PlayerRankings
  class CreateOrUpdatePlayerRankingWeek
    include Service

    def initialize(rank_range, week_date)
      @rank_range = rank_range
      @week_date = week_date
    end

    def call
      puts "Starting the player rankings data scraping process for week: #{week_date}..."

      player_rankings_data = PlayerRankings::PlayerRankingWeekScraper.new(rank_range, week_date).fetch

      player_rankings_data.each do |ranking_data|
        player_ranking_data = {
          full_name: ranking_data[:full_name],
          tennis_player_slug: ranking_data[:tennis_player_slug],
          player_url: ranking_data[:player_url],
          ranking: ranking_data[:ranking],
          week_date: week_date
        }

        tennis_player = TennisPlayer.find_or_initialize_by(tennis_player_slug: ranking_data[:tennis_player_slug])
        tennis_player.update!(
          full_name: ranking_data[:full_name],
          player_url: ranking_data[:player_url]
        )

        player_ranking = PlayerRanking.find_or_initialize_by(
          tennis_player: tennis_player,
          week_date: week_date
        )
        player_ranking.update!(ranking: ranking_data[:ranking])
      end

      puts "Finished player rankings data scraping process for week: #{week_date}."
    end

    private

    attr_reader :rank_range, :week_date
  end
end
