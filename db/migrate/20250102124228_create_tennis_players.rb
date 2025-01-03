class CreateTennisPlayers < ActiveRecord::Migration[8.0]
  def change
    create_table :tennis_players do |t|
      t.string :full_name, null: false
      t.date :date_of_birth
      t.integer :height
      t.string :handedness
      t.string :backhand

      t.timestamps
    end
  end
end
