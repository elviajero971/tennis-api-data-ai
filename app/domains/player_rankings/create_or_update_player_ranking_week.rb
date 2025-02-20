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

      # add guard if no player_rankings_data

      return if player_rankings_data.empty?

      player_rankings_data.each do |ranking_data|

        tennis_player = TennisPlayer.find_or_initialize_by(tennis_player_slug: ranking_data[:tennis_player_slug])

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
