# Model for a Game between two Fantasy Football Teams
class Game < ActiveRecord::Base
  belongs_to :team, foreign_key: :team_id
end
