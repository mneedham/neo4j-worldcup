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

	next if year == "2010"
	
	@doc = Nokogiri::HTML(open(match_file))
	world_cup = @doc.css("div.content_header h1").text
	
	home_team =  @doc.css("div.lnupTeam").first
	home_team.css("ul:nth-child(2) li").each do |row|
		player = row.css("div.playerInfo span").text
		MATCHES[match_id][:home][:starting] << Functions.clean_up_player(player)
	end
	
	home_team.css("ul:nth-child(3) li").each do |row|
		player = row.css("div.playerInfo span").text
		MATCHES[match_id][:home][:subs] << Functions.clean_up_player(player)
	end

	away_team = @doc.css("div.lnupTeam.away")
	away_team.css("ul:nth-child(2) li").each do |row|
		player = row.css("div.playerInfo span").text
		MATCHES[match_id][:away][:starting] << Functions.clean_up_player(player)
	end
	
	away_team.css("ul:nth-child(3) li").each do |row|
		player = row.css("div.playerInfo span").text
		MATCHES[match_id][:away][:subs] << Functions.clean_up_player(player)
	end	

	MATCHES[match_id] = MATCHES[match_id].merge( {:world_cup => world_cup})
end

open("data/import/lineups.csv", 'w') { |f|	
	f.puts (["world_cup",
		     "match_id", 
			 "team",
			 "type",
			 "player",
			 ""]).join(",")

  	MATCHES.each do |match_id, row|
  		row[:home][:starting].each do |player|
			f.puts ["\"#{row[:world_cup]}\"",
			        "\"#{match_id}\"",
			    	"\"home\"",
			   		"\"starting\"" ,
					"\"#{player}\""
					].join(",")
  		end

  		row[:home][:subs].each do |player|
			f.puts ["\"#{row[:world_cup]}\"",
			        "\"#{match_id}\"",
			    	"\"home\"",
			   		"\"sub\"" ,
					"\"#{player}\""
					].join(",")
  		end  

  		row[:away][:starting].each do |player|
			f.puts ["\"#{row[:world_cup]}\"",
			        "\"#{match_id}\"",
			    	"\"away\"",
			   		"\"starting\"" ,
					"\"#{player}\""
					].join(",")
  		end

  		row[:away][:subs].each do |player|
			f.puts ["\"#{row[:world_cup]}\"",
			        "\"#{match_id}\"",
			    	"\"away\"",
			   		"\"sub\"" ,
					"\"#{player}\""
					].join(",")
  		end 
	end
}