require "nokogiri"
require 'open-uri'
require 'date'

POSITIONS = {"Goalkeepers" => "GK", "Defenders" => "DF", "Midfielders" => "MF",	"Forwards" => "FW"}
SQUADS = {}


team_files = Dir["data/teams/*"]

team_files.select {|file| !file.end_with? ".md" }.each do |team_file|
	year, team = team_file.gsub(/\.html/, "").split("/")[-1].split("-")


	SQUADS[year] ||= {}
	SQUADS[year][team] ||= []
	
	@doc = Nokogiri::HTML(open(team_file))

	if year == "2010"
		players = @doc.css("div.squadList table tr")
		current_position = nil
		players.each do |player|			
			unless player.css("td.titlepos").text.empty?				
				current_position = player.css(".titlepos").text		
			else
				next if current_position == "Coach"
				number = player.css("td:nth-child(1)").text
				pos = POSITIONS[current_position]
				profile = player.css("td:nth-child(2)")
				name = profile.text
				link = profile.css("a").empty? ? "" : profile.css("a").attr("href").value

				number = player.css("td:nth-child(1)").text
				
				SQUADS[year][team] << {
					:player_id => link.split("/")[-2].split("=")[1],
					:player => name.split(" ").map(&:capitalize).join(" "),
					:position => pos,
					:squad_number => number
				}
			end
		end
	else
		@doc.css("table.teamstat tbody tr").each do |row|
			# puts row
			player = row.css("td:nth-child(2) a")
			dob = row.css("td:nth-child(3)")
			position = row.css("td:nth-child(4)")
			
			SQUADS[year][team] << { :player_id => player.attr('href').text.split("/")[-2].split("=")[1],
									:player => player.text.split(" ").map(&:capitalize).join(" "), 
									:dob => dob.text, 
									:position => position.text
								  }
		end
	end

	puts "#{team} #{year}"
end

open("data/import/squads.csv", 'w') { |f|	
	f.puts (["year",
		     "country", 
			 "player_id", 
			 "player_name", 
			 "dob", 
			 "position"]).join(",")

	SQUADS.each do |year, rest|
		rest.each do |team, players|
			players.each do |player|
				f.puts ["\"#{year}\"",
						"\"#{team}\"", 
						"\"#{player[:player_id]}\"",
						"\"#{player[:player]}\"",
						"\"#{player[:dob]}\"",
						"\"#{player[:position]}\""
						].join(",")
			end

		end
	end
}