class TennisPlayer < ApplicationRecord
  has_many :player_rankings, dependent: :destroy
  has_many :matches_as_player_1, class_name: "Match", foreign_key: "player_1_id"
  has_many :matches_as_player_2, class_name: "Match", foreign_key: "player_2_id"
  has_many :matches_as_winner, class_name: "Match", foreign_key: "player_winner_id"

  validates :tennis_player_slug, presence: true, uniqueness: true
end
