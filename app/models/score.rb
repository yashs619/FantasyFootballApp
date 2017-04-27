# Weekly Score of a Player
class Score < ActiveRecord::Base
  belongs_to :player, foreign_key: :player_id
end
