class AddMatchScoreToMatches < ActiveRecord::Migration[8.0]
  def change
    add_column :matches, :score, :string
    add_column :matches, :ending, :string
  end
end
