class AddSlugAndUrlToTennisPlayers < ActiveRecord::Migration[8.0]
  def change
    add_column :tennis_players, :tennis_player_slug, :string
    add_column :tennis_players, :player_url, :string

    # Add an index on `tennis_player_slug` to make lookups faster
    add_index :tennis_players, :tennis_player_slug, unique: true
  end
end
