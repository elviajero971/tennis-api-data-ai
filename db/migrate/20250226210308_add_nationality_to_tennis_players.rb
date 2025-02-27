class AddNationalityToTennisPlayers < ActiveRecord::Migration[8.0]
  def change
    add_column :tennis_players, :nationality, :string
  end
end
