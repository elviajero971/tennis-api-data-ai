class TournamentYear < ApplicationRecord
  has_many :matches

  validates :tournament_year, presence: true
  validates :tournament_slug, presence: true
  validates :tournament_reference, presence: true
end
