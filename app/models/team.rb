# Fantasy Football Team
class Team < ActiveRecord::Base
  has_many :activePlayers, class_name: 'Player'
  has_many :benchedPlayers, class_name: 'Player'
  has_many :teamRanks
  has_many :games
end
