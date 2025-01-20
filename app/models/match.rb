class Match < ApplicationRecord
  belongs_to :tournament_year
  belongs_to :player_1, class_name: 'TennisPlayer', optional: true
  belongs_to :player_2, class_name: 'TennisPlayer', optional: true
  belongs_to :player_winner, class_name: 'TennisPlayer', optional: true

  validates :tournament_slug, :tournament_reference, :player_1_slug, :player_2_slug, presence: true
end
