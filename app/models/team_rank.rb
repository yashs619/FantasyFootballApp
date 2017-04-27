# Weekly Rank of a Team
class TeamRank < ActiveRecord::Base
  belongs_to :team, foreign_key: :team_id
end
