class CreateMatches < ActiveRecord::Migration[8.0]
  def change
    create_table :matches do |t|
      t.integer :tournament_year_id, null: false  # Foreign key for TournamentYear
      t.string :tournament_slug, null: false
      t.string :tournament_reference, null: false
      t.string :round
      t.integer :duration
      t.integer :year_of_tournament

      # Foreign keys for TennisPlayer (Player 1, Player 2, and Winner)
      t.integer :player_1_id, null: false        # Foreign key for TennisPlayer
      t.integer :player_2_id, null: false        # Foreign key for TennisPlayer
      t.integer :player_winner_id                # Foreign key for TennisPlayer (winner)

      # Original slugs for reference
      t.string :player_1_slug, null: false
      t.string :player_2_slug, null: false
      t.string :player_winner_slug

      t.timestamps
    end

    add_index :matches, :tournament_year_id
    add_index :matches, :player_1_id
    add_index :matches, :player_2_id
    add_index :matches, :player_winner_id
  end
end
