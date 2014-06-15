require 'csv'

players = []
CSV.foreach("data/import/players_with_dups.csv", :headers => true) do |row|
  players << row
end

PLAYERS = {}
players.group_by { |x| x["year"]}.each do |key, values|
	PLAYERS[key] ||= {}

	values.each do |value|		
		PLAYERS[key][value['team']] ||= {}
		PLAYERS[key][value['team']][value['player_name']] = value['player_id']
	end	
end

players.group_by { |x| x["player_id"] }.each do |key, values|
	player_names  = values.map {|x| x['player_name']}.uniq	

    # p player_names if player_names.count > 1
end