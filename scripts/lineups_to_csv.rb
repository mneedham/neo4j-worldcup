#encoding: UTF-8

require "nokogiri"
require 'open-uri'
require 'date'
require_relative 'functions.rb'

all_the_matches = File.readlines("data/matches.csv").
                       map { |row| row.gsub(/\n/, "").split(",") }

MATCHES = {}

all_the_matches.each do |match|
	match_id = match[5].gsub(/\.html/, "").split("/")[-2].split("=")[1]
	MATCHES[match_id] = {
		:match_number => match[-1],
		:year => match[0],
		:home => { :starting => [], :subs => [] },
		:away => { :starting => [], :subs => [] }
	}
end

match_files = Dir["data/matches/*"]

match_files.select {|file| !file.end_with? ".md" }.each do |match_file|
	match_id = match_file.gsub(/\.html/, "").split("/")[-1]
	puts match_id
	year = MATCHES[match_id][:year]
		
	@doc = Nokogiri::HTML(open(match_file))
	world_cup = @doc.css("div.content_header h1").text

	player_id_lookup = Functions.player_id_lookup

	if year == "2010"
		home_team = @doc.css(".mh_header h1 a").first.text
		away_team = @doc.css(".mh_header h1 a")[1].text

		@doc.css("table#squads td.l").each do |row|	
			player = row.css(".playerdata .c-name").text
			name = Functions.clean_up_player(player)
			MATCHES[match_id][:home][:starting] << { 
				:name => name, 
				:id => player_id_lookup[year][home_team][name]
			}
		end
		
		@doc.css("table#substitutes td.l").each do |row|	
			player = row.css(".playerdata .c-name").text
			name = Functions.clean_up_player(player)
			MATCHES[match_id][:home][:subs] << { 
				:name => name, 
				:id => player_id_lookup[year][home_team][name]
			}
		end		

		@doc.css("table#squads td.r").each do |row|	
			player = row.css(".playerdata .c-name").text
			name = Functions.clean_up_player(player)
		
			MATCHES[match_id][:away][:starting] << { 
				:name => name, 
				:id => player_id_lookup[year][away_team][name]
			}
		end

		@doc.css("table#substitutes td.r").each do |row|	
			player = row.css(".playerdata .c-name").text
			name = Functions.clean_up_player(player)
			MATCHES[match_id][:away][:subs] << { 
				:name => name, 
				:id => player_id_lookup[year][away_team][name]
			}
		end			
	else
		home, away = @doc.css("div.teams").text.split("-").map(&:strip)

		home_team =  @doc.css("div.lnupTeam").first
		home_team.css("ul:nth-child(2) li").each do |row|
			player = row.css("div.playerInfo span").text
			name = Functions.clean_up_player(player) 
			MATCHES[match_id][:home][:starting] << {
				:name => name,
				:id => player_id_lookup[year][home][name]
			}
		end
		
		home_team.css("ul:nth-child(3) li").each do |row|
			player = row.css("div.playerInfo span").text
			name = Functions.clean_up_player(player) 
			MATCHES[match_id][:home][:subs] << {
				:name => name,
				:id => player_id_lookup[year][home][name]
			}
		end

		away_team = @doc.css("div.lnupTeam.away")
		away_team.css("ul:nth-child(2) li").each do |row|
			player = row.css("div.playerInfo span").text
			name = Functions.clean_up_player(player) 
			MATCHES[match_id][:away][:starting] << {
				:name => name,
				:id => player_id_lookup[year][away][name]
			}
		end
		
		away_team.css("ul:nth-child(3) li").each do |row|
			player = row.css("div.playerInfo span").text
			name = Functions.clean_up_player(player) 
			MATCHES[match_id][:away][:subs] << {
				:name => name,
				:id => player_id_lookup[year][away][name]
			}
		end	
	end

	MATCHES[match_id] = MATCHES[match_id].merge( {:world_cup => world_cup})
end

open("data/import/lineups.csv", 'w') { |f|	
	f.puts (["world_cup",
		     "match_id", 
			 "team",
			 "type",
			 "player",
			 "player_id"]).join(",")

  	MATCHES.each do |match_id, row|
  		row[:home][:starting].each do |player|
			f.puts ["\"#{row[:world_cup]}\"",
			        "\"#{match_id}\"",
			    	"\"home\"",
			   		"\"starting\"" ,
					"\"#{player[:name]}\"",
					"\"#{player[:id]}\""
					].join(",")
  		end

  		row[:home][:subs].each do |player|
			f.puts ["\"#{row[:world_cup]}\"",
			        "\"#{match_id}\"",
			    	"\"home\"",
			   		"\"sub\"" ,
					"\"#{player[:name]}\"",
					"\"#{player[:id]}\""
					].join(",")
  		end  

  		row[:away][:starting].each do |player|
			f.puts ["\"#{row[:world_cup]}\"",
			        "\"#{match_id}\"",
			    	"\"away\"",
			   		"\"starting\"" ,
					"\"#{player[:name]}\"",
					"\"#{player[:id]}\""
					].join(",")
  		end

  		row[:away][:subs].each do |player|
			f.puts ["\"#{row[:world_cup]}\"",
			        "\"#{match_id}\"",
			    	"\"away\"",
			   		"\"sub\"" ,
					"\"#{player[:name]}\"",
					"\"#{player[:id]}\""
					].join(",")
  		end 
	end
}