class UpdateFieldsForTennisPlayers < ActiveRecord::Migration[8.0]
  def change
    # change name of the column career_wins_and_losses to career_wins_and_losses_singles and so on
    rename_column :tennis_players, :nb_career_wins, :nb_career_wins_singles
    rename_column :tennis_players, :nb_career_losses, :nb_career_losses_singles
    rename_column :tennis_players, :nb_career_matches, :nb_career_matches_singles
    rename_column :tennis_players, :nb_career_titles, :nb_career_titles_singles
    rename_column :tennis_players, :career_highest_ranking, :career_highest_ranking_singles
    rename_column :tennis_players, :career_highest_ranking_date, :career_highest_ranking_date_singles
    rename_column :tennis_players, :playing_style, :play_hand
    rename_column :tennis_players, :weight, :weight_in_kg
    rename_column :tennis_players, :height, :height_in_cm

    add_column :tennis_players, :nb_career_wins_doubles, :integer
    add_column :tennis_players, :nb_career_losses_doubles, :integer
    add_column :tennis_players, :nb_career_matches_doubles, :integer
    add_column :tennis_players, :nb_career_titles_doubles, :integer
    add_column :tennis_players, :career_highest_ranking_doubles, :integer
    add_column :tennis_players, :career_highest_ranking_date_doubles, :date
    add_column :tennis_players, :back_hand, :string
    add_column :tennis_players, :active_player, :boolean, default: true
    add_column :tennis_players, :double_specialist, :boolean, default: false
  end
end
