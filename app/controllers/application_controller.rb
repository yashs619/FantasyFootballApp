# Location for helper methods of other controllers
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method def get_active_players(page, week)
    player = 0
    current_players = []
    while player < 8
      while page.css('#row_0_0_' + player.to_s + ' .player-text').text.empty? && player < 8
        player += 1
      end

      if player < 8
        current_player = Player.find_by(name: page.css('#row_0_0_' + player.to_s + ' .player-text').text)
        if current_player.nil?
          pos_info = page.css('#row_0_0_' + player.to_s + ' .position')[0].text + ' ' + page.css('#row_0_0_' + player.to_s + ' .player-team').text
          current_player = Player.new(name: page.css('#row_0_0_' + player.to_s + ' .player-text').text, posInfo: pos_info)
        end

        if current_player.scores.to_a.find { |score| score.week == week }.nil?
          current_player.scores << Score.create(value: page.css('#row_0_0_' + player.to_s +  ' .points-final').text.to_f, week: week)
        end

        current_player.rank = page.css('#row_0_0_' + player.to_s + ' td')[5].text.to_i

        current_players << current_player
        player += 1
      end
    end
    current_players
  end

  helper_method def get_benched_players(page, week)
    player = 0
    current_players = []
    while player < 10 
      while page.css('#row_0_1_' + player.to_s + ' .player-text').text.empty? && player < 10 do
        player += 1
      end
      if player < 10
        current_player = Player.find_by(name: page.css('#row_0_1_' + player.to_s + ' .player-text').text)
        if current_player.nil?
          pos_info = page.css('#row_0_1_' + player.to_s + ' .position')[0].text + ' ' + page.css('#row_0_1_' + player.to_s + ' .player-team').text
          current_player = Player.new(name: page.css('#row_0_1_' + player.to_s + ' .player-text').text, posInfo: pos_info)
        end

        if current_player.scores.to_a.find { |score| score.week == week }.nil?
          current_player.scores << Score.create(value: page.css('#row_0_1_' + player.to_s + ' .points-final').text.to_f, week: week)
        end

        current_player.rank = page.css('#row_0_1_' + player.to_s + ' td')[5].text.to_i

        current_players << current_player
        player += 1
      end
    end
    current_players
  end

  helper_method def replace_active_players(team, current_active_players)
    (team.benchedPlayers.to_a & current_active_players).each do |player|
      team.activePlayers << player
      player.save
    end

    current_active_players.each do |player|
      if !(team.activePlayers.include? player)
        @team.activePlayers << player
        player.save
      end
    end

    free_agent_team = Team.find_by(name: 'Free_Agent_Group')
    team.activePlayers.each do |player|
      if !(current_active_players.include? player)
        team.activePlayers.delete(player)
        free_agent_team.activePlayers << player
        player.save
      end
    end
  end

  helper_method def replace_benched_players(team, current_benched_players)
    (team.activePlayers.to_a & current_benched_players).each do |player|
      team.benchedPlayers << player
      player.save
    end

    current_benched_players.each do |player|
      if !(team.benchedPlayers.include? player)
        team.benchedPlayers << player
        player.save
      end
    end

    free_agent_team = Team.find_by(name: 'Free_Agent_Group')
    team.benchedPlayers.each do |player|
      if !(current_benched_players.include? player)
        team.benchedPlayers.delete(player)
        free_agent_team.activePlayers << player
        player.save
      end
    end
  end

  helper_method def cardinalize(ordinal)
    ordinal = ordinal.split('')
    if ordinal[0] == '1' && ordinal[1] == '0'
      10
    else
      ordinal[0].to_i
    end
  end

  helper_method def get_weekly_data(page, team, week)
    if week > 0 && week < 14
      get_week_minus1_data(page, team, week)
    elsif week == 14
      if page.css('#row_0_0_' + (week - 1).to_s + ' .left')[0].text.split(' ')[0].to_i == week
        get_week_minus1_data(page, team, week)
      else
        team.games.find_by(week: week).destroy unless team.games.find_by(week: week).nil?
        false
      end
    elsif week == 15
      if page.css('#row_0_0_' + (week - 1).to_s + ' .left')[0].nil?
        team.games.find_by(week: week).destroy unless team.games.find_by(week: week).nil?
        false
      elsif page.css('#row_0_0_' + (week - 1).to_s + ' .left')[0].text.split(' ')[0].to_i == week
        get_week_minus1_data(page, team, week)
      elsif page.css('#row_0_0_' + (week - 1).to_s + ' .left')[0].text.split(' ')[0].to_i == week + 1
        get_week_minus2_data(page, team, week)
      end
    else # week == 16
      if page.css('#row_0_0_' + (week - 1).to_s + ' .left')[0].nil? && page.css('#row_0_0_' + (week - 2).to_s + ' .left')[0].nil?
        team.games.find_by(week: week).destroy unless team.games.find_by(week: week).nil?
        false
      elsif page.css('#row_0_0_' + (week - 1).to_s + ' .left')[0].nil? && page.css('#row_0_0_' + (week - 2).to_s + ' .left')[0].text.split(' ')[0].to_i == week
        get_week_minus2_data(page, team, week)
      elsif page.css('#row_0_0_' + (week - 1).to_s + ' .left')[0].nil? && page.css('#row_0_0_' + (week - 2).to_s + ' .left')[0].text.split(' ')[0].to_i != week
        team.games.find_by(week: week).destroy unless team.games.find_by(week: week).nil?
        false
      else # normal
        get_week_minus1_data(page, team, week)
      end
    end
  end

  helper_method def get_week_minus1_data(page, team, week)
    week_rank = cardinalize(page.css('#row_0_0_' + (week - 1).to_s + ' td')[4].text)
    if team.teamRanks.to_a.find { |rank| rank.week == week }.nil?
      team.teamRanks << TeamRank.create(rank: week_rank, week: week)
    end
    
    opponent = page.css('#row_0_0_' + (week - 1).to_s + ' .league-name').text
    game_info = page.css('#row_0_0_' + (week - 1).to_s + ' td')[3].text.split(' ')

    game = team.games.find_by(week: week)

    if game.nil?
      game = Game.new(opponent: opponent, week: week)
    end

    if game_info[0] == 'W'
      game.win = true
    else
      game.win = false
    end

    game_info = game_info[1].split('-')
    game.myPoints = game_info[0].to_f
    game.oppPoints = game_info[1].to_f
    team.games << game if team.games.find_by(week: week).nil?
    game.save
  end

  helper_method def get_week_minus2_data(page, team, week)
    week_rank = cardinalize(page.css('#row_0_0_' + (week - 2).to_s + ' td')[4].text)
    if team.teamRanks.to_a.find { |rank| rank.week == week }.nil?
      team.teamRanks << TeamRank.create(rank: week_rank, week: week)
    end 

    opponent = page.css('#row_0_0_' + (week - 2).to_s + ' .league-name').text
    game_info = page.css('#row_0_0_' + (week - 2).to_s + ' td')[3].text.split(' ')

    game = team.games.find_by(week: week)

    if game.nil?
      game = Game.new(opponent: opponent, week: week)
    end

    if game_info[0] == 'W'
      game.win = true
    else
      game.win = false
    end

    game_info = game_info[1].split('-')
    game.myPoints = game_info[0].to_f
    game.oppPoints = game_info[1].to_f
    team.games << game if team.games.find_by(week: week).nil?
    game.save
  end

  helper_method def get_highest_lowest_average_score(team)
    lowest = team.games.to_a[0].myPoints
    highest = team.games.to_a[0].myPoints
    average = 0.0
    team.games.each do |game|
      average += game.myPoints
      if game.myPoints > highest
        highest = game.myPoints
      elsif game.myPoints < lowest
        lowest = game.myPoints
      end
    end
    average /= team.games.size
    [average, highest, lowest]
  end
end
