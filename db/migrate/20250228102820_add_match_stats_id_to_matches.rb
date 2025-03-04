class AddMatchStatsIdToMatches < ActiveRecord::Migration[8.0]
  def change
    add_column :matches, :match_stats_id, :string
  end
end
