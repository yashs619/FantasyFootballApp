class WelcomeController < ApplicationController
  def index
    @teams = Team.all
    source = Net::HTTP.get(URI('https://www.fleaflicker.com/nfl/leagues/166321?season=2016'))
    page = Nokogiri::HTML(source)

    player = 0
    while player < 5
      team = Team.find_by(name: page.css('#row_0_0_' + player.to_s + ' td .league-name').text)
      team.finalRank = page.css('#row_0_0_' + player.to_s + ' td')[18].text.to_i
      team.save
      player += 1
    end

    player = 0
    while player < 5
      team = Team.find_by(name: page.css('#row_0_1_' + player.to_s + ' td .league-name').text)
      puts 'THIS IS TEAM NAME'
      puts page.css('#row_0_1_' + player.to_s + ' td .league-name').text
      team.finalRank = page.css('#row_0_1_' + player.to_s + ' td')[18].text.to_i
      team.save
      player += 1
    end
  end
end
