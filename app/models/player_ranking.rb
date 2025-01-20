class PlayerRanking < ApplicationRecord
  belongs_to :tennis_player

  validates :week_date, :ranking, presence: true
  validates :ranking, numericality: { only_integer: true, greater_than: 0 }
  validates :week_date, uniqueness: { scope: :tennis_player_id, message: "Ranking already exists for this week" }
end
