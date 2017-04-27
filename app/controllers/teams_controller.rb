# Controller for Team Pages
class TeamsController < ApplicationController
  # GET /teams/:team_id
  def index
    @team = Team.find_by(id: params[:team_id])
    if @team.teamRanks.find_by(week: 16).nil?
      source = Net::HTTP.get(URI('https://www.fleaflicker.com/nfl/leagues/166321/teams/' + @team.teamNumber.to_s + '?season=2016&week=16'))
      page = Nokogiri::HTML(source)
      @team.teamRanks << TeamRank.create(rank: page.css('.tt-content')[1].text.to_i, week: 16)
      @team.save
    end
    @arr = get_highest_lowest_average_score(@team)
    @teams = Team.all
  end

  # GET /teams/:team_id/week/:id
  def week
    @team = Team.find_by(id: params[:team_id])
    source = Net::HTTP.get(URI('https://www.fleaflicker.com/nfl/leagues/166321/teams/' + @team.teamNumber.to_s + '?season=2016&week=' + params[:id]))
    page = Nokogiri::HTML(source)
    replace_active_players(@team, get_active_players(page, params[:id].to_i))
    replace_benched_players(@team, get_benched_players(page, params[:id].to_i))

    week_source = Net::HTTP.get(URI('https://www.fleaflicker.com/nfl/leagues/166321/teams/' + @team.teamNumber.to_s + '/schedule?season=2016'))
    page_week = Nokogiri::HTML(week_source)
    @week14 = get_weekly_data(page_week, @team, params[:id].to_i)
    @game = @team.games.find_by(week: params[:id].to_i)
    if !@game.nil? && @game.win == true
      @result = 'won'
    else
      @result = 'lost'
    end
    @teams = Team.all
  end
end
