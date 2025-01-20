module PlayerRankings
  class CreateOrUpdatePlayerRanking
    include Service
    def initialize(full_name:, tennis_player_slug:, player_url:, ranking:, week_date:)
      @full_name = full_name
      @tennis_player_slug = tennis_player_slug
      @player_url = player_url
      @ranking = ranking
      @week_date = week_date
    end

    def call
      ActiveRecord::Base.transaction do
        tennis_player = find_or_create_tennis_player
        create_or_update_player_ranking(tennis_player)
      end
    end

    private

    attr_reader :full_name, :tennis_player_slug, :player_url, :ranking, :week_date

    def find_or_create_tennis_player
      player = TennisPlayer.find_or_initialize_by(tennis_player_slug: tennis_player_slug)
      puts "Creating or updating player: #{full_name} with slug: #{tennis_player_slug}, url: #{player_url}, and ranking: #{ranking}, on #{week_date} ranking"
      player.update!(full_name: full_name, player_url: player_url)
      player
    end

    def create_or_update_player_ranking(tennis_player)
      puts "Creating or updating player ranking for #{tennis_player.full_name} on #{week_date} ranking: #{ranking}"
      PlayerRanking.create(tennis_player: tennis_player, week_date: week_date, ranking: ranking)
    end
  end
end
