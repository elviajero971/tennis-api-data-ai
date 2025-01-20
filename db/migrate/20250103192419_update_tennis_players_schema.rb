class UpdateTennisPlayersSchema < ActiveRecord::Migration[8.0]
  def change
    change_table :tennis_players do |t|
      t.integer :career_highest_ranking
      t.date :career_highest_ranking_date
      t.decimal :career_prize_money, precision: 15, scale: 0
      t.string :playing_style
    end

    remove_column :tennis_players, :handedness, :string
    remove_column :tennis_players, :backhand, :string
  end
end
