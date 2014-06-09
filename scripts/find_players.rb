require "nokogiri"
require 'open-uri'

all_teams = Dir["data/teams/*"]

positions = {"Goalkeepers" => "GK", "Defenders" => "DF", "Midfielders" => "MF",	"Forwards" => "FW"}

all_teams.each do |file|
	@doc = Nokogiri::HTML(open(file))
	year, team = file.gsub(/\.html/, "").split("/")[-1].split("-")

	unless file.start_with?("data/teams/2010")
		players = @doc.css("table.teamstat tbody tr")
		players.each do |player|
			number = player.css("td:nth-child(1)").text
			name = player.css("td:nth-child(2)").text
			link = player.css("td:nth-child(2) a").attr('href').value
			position = player.css("td:nth-child(4)").text
			height = player.css("td:nth-child(5)").text
			puts "#{year},#{team},#{name},#{number},#{position},#{height},#{link}"
		end
	else
		players = @doc.css("div.squadList table tr")				

		current_position = nil
		players.each do |player|
			
			unless player.css("td.titlepos").text.empty?				
				current_position = player.css(".titlepos").text		
			else
				next if current_position == "Coach"
				number = player.css("td:nth-child(1)").text
				pos = positions[current_position]
				profile = player.css("td:nth-child(2)")
				name = profile.text
				link = profile.css("a").empty? ? "" : profile.css("a").attr("href").value

				number = player.css("td:nth-child(1)").text
				
				puts "#{year},#{team},#{name},#{number},#{pos},#{link}"
			end
		end
	end
end

