class CreatePlayerRanking < ActiveRecord::Migration[8.0]
  def change
    create_table :player_rankings do |t|
      t.references :tennis_player, null: false, foreign_key: true
      t.date :week_date
      t.integer :ranking

      t.timestamps
    end
  end
end
