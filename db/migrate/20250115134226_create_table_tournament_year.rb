class CreateTableTournamentYear < ActiveRecord::Migration[8.0]
  def change
    create_table :tournament_years do |t|
      t.string :tournament_reference
      t.string :tournament_slug
      t.string :tournament_name
      t.string :tournament_category
      t.string :tournament_type
      t.string :tournament_winner_single_tennis_player_slug
      t.integer :tournament_year

      t.timestamps
    end
  end
end
