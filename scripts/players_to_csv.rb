require "nokogiri"
require 'open-uri'
require 'date'
require_relative 'functions.rb'

PLAYERS = []

team_files = Dir["data/teams/*"]

team_files.select {|file| !file.end_with? ".md" }.each do |team_file|
	year, team = team_file.gsub(/\.html/, "").split("/")[-1].split("-")
	
	@doc = Nokogiri::HTML(open(team_file))

	if year == "2010"
		players = @doc.css("div.squadList table tr")
		current_position = nil
		players.each do |player|			
			unless player.css("td.titlepos").text.empty?				
				current_position = player.css(".titlepos").text		
			else
				next if current_position == "Coach"
						
				profile = player.css("td:nth-child(2)")
				name = profile.text
				link = profile.css("a").empty? ? "" : profile.css("a").attr("href").value

				number = player.css("td:nth-child(1)").text
				
				PLAYERS << {
					:player_id => link.split("/")[-2].split("=")[1],
					:player => Functions.clean_up_player(name),
					:year => year,
					:team => team
				}
			end
		end
	else
		@doc.css("table.teamstat tbody tr").each do |row|
			# puts row
			player = row.css("td:nth-child(2) a")
			dob = row.css("td:nth-child(3)")
			position = row.css("td:nth-child(4)")
			
			PLAYERS << { :player_id => player.attr('href').text.split("/")[-2].split("=")[1],
						 :player => Functions.clean_up_player(player.text),
						 :year => year,
						 :team => team
					   }
		end
	end
end
puts "team files done"

players_files = Dir["data/players/*"]

players_files.select {|file| !file.end_with? ".md" }.each do |player_file|
	parts = player_file.gsub(/\.html/, "").split("/")[-1].split("-")
	year, team, player_id = parts
	
	@doc = Nokogiri::HTML(open(player_file))
	player = @doc.css("div.title h1").text

	PLAYERS << { :player_id => player_id,
				 :player => Functions.clean_up_player(player),
				 :year => year,
				 :team => team				 
			   }	
end

open("data/import/players_with_dups.csv", 'w') { |f|	
	f.puts (["player_id", 
			 "player_name",
			 "year",
			 "team"]).join(",")

	PLAYERS.uniq.each do |player|
		f.puts ["\"#{player[:player_id]}\"",
				"\"#{player[:player]}\"",
		        "\"#{player[:year]}\"",
		        "\"#{player[:team]}\""
				].join(",")
	end
}