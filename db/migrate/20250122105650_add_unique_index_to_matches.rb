class AddUniqueIndexToMatches < ActiveRecord::Migration[8.0]
  def change
    add_index :matches, [ :tournament_year_id, :player_1_id, :player_2_id ], unique: true, name: 'index_matches_on_year_and_players'
  end
end
