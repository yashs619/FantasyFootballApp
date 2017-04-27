# Actual NFL Player
class Player < ActiveRecord::Base
  belongs_to :team, foreign_key: :team_id
  has_many :scores
end
