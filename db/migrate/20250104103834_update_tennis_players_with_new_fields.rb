class UpdateTennisPlayersWithNewFields < ActiveRecord::Migration[8.0]
  def change
    add_column :tennis_players, :age, :integer
    add_column :tennis_players, :weight, :integer
    add_column :tennis_players, :place_of_birth, :string
    add_column :tennis_players, :current_coach, :string
    add_column :tennis_players, :nb_career_titles, :integer
    add_column :tennis_players, :nb_career_wins, :integer
    add_column :tennis_players, :nb_career_losses, :integer
    add_column :tennis_players, :nb_career_matches, :integer

    change_column :tennis_players, :career_prize_money, :decimal, precision: 15, scale: 2, null: true
    change_column :tennis_players, :playing_style, :string, null: true
    change_column :tennis_players, :career_highest_ranking, :integer, null: true
    change_column :tennis_players, :career_highest_ranking_date, :date, null: true
  end
end
