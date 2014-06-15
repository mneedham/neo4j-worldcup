require "nokogiri"
require 'open-uri'
require 'date'
require_relative 'functions.rb'

all_the_matches = File.readlines("data/matches.csv").
                       map { |row| row.gsub(/\n/, "").split(",") }

MATCHES = {}

all_the_matches.each do |match|
	match_id = match[5].gsub(/\.html/, "").split("/")[-2].split("=")[1]
	MATCHES[match_id] = match[0]
end

COUNTRY_CODES = {}
cc = File.readlines("data/cc.csv").
                       map { |row| row.gsub(/\n/, "").split(",") }

cc.each {|k, v| COUNTRY_CODES[k] = v.strip }

all_the_matches = File.readlines("data/matches.csv").
                       map { |row| row.gsub(/\n/, "").split(",") }

EVENTS = []

player_id_lookup = Functions.player_id_lookup

match_files = Dir["data/matches/*"]
match_files.select {|file| !file.end_with?(".md") && !file.include?("stats") }.each do |match_file|
	match_id = match_file.gsub(/\.html/, "").split("/")[-1]
	year = MATCHES[match_id]
	puts "processing #{match_id}"
	
	@doc = Nokogiri::HTML(open(match_file))	
	world_cup = @doc.css("div.content_header h1").text

	if year == "2010"
		@doc = Nokogiri::HTML(open("data/matches/stats/#{match_id}.html"))	

		@doc.css("div.scorers ul.shome li").each do |scorer|
			if Functions.multiple_goals?(scorer.text)
				goals = Functions.process_multiple_scorer(scorer.text, COUNTRY_CODES, player_id_lookup[year][:all])
				goals.each do |goal|
					EVENTS << {:match_id => match_id}.merge(goal)
				end
			else
				vals = Functions.process_scorer(scorer.text, COUNTRY_CODES, player_id_lookup[year][:all])
				EVENTS << {:match_id => match_id}.merge(vals)
			end			
		end

		@doc.css("div.scorers ul.saway li").each do |scorer|
			if Functions.multiple_goals?(scorer.text)
				goals = Functions.process_multiple_scorer(scorer.text, COUNTRY_CODES, player_id_lookup[year][:all])
				goals.each do |goal|
					EVENTS << {:match_id => match_id}.merge(goal)
				end
			else
				vals = Functions.process_scorer(scorer.text, COUNTRY_CODES, player_id_lookup[year][:all])
				EVENTS << {:match_id => match_id}.merge(vals)
			end	
		end		

		@doc.css("table.cards ul li").each do |row|
			player = row.css("span:nth-child(2)")

			if player.count == 0
				player = row.css("div")
			end

			yellow = row.css("span.icon-events-yellow")
			yellowred = row.css("span.icon-events-yellow2red")
			red = row.css("span.icon-events-red")

			vals = Functions.process_card(player.text, COUNTRY_CODES, player_id_lookup[year][:all])

			if yellow.count > 0 
				EVENTS << {:match_id => match_id, :type => "yellow"}.merge(vals)
			end

			if yellowred.count > 0 
				EVENTS << {:match_id => match_id, :type => "yellowred"}.merge(vals)
			end

			if red.count > 0 
				EVENTS << {:match_id => match_id, :type => "red"}.merge(vals)
			end			
			
		end		
	else
		scorers = @doc.css("div.cont:nth-child(4) li")

		current_scorer = nil
		scorers.each do |scorer|
			current_scorer = scorer.text if current_scorer.nil?
			if scorer.text.start_with? " "
				time = scorer.text.match(/(\d{1,3})'/)[1]
				current_scorer = current_scorer.gsub(/\d{1,3}/, time)
			else
				current_scorer = scorer.text
			end			

			vals = Functions.process_scorer(current_scorer, COUNTRY_CODES, player_id_lookup[year][:all])
			EVENTS << {:match_id => match_id}.merge(vals)
		end	

		yellows = @doc.css("div.cont:nth-child(6) li")

		yellows.each do |scorer|
			next if scorer.text.start_with? ", "
			vals = Functions.process_card(scorer.text, COUNTRY_CODES, player_id_lookup[year][:all])

			EVENTS << {:match_id => match_id, :type => "yellow"}.merge(vals)
		end

		reds = @doc.css("div.cont:nth-child(7) li")

		reds.each do |scorer|
			vals = Functions.process_card(scorer.text, COUNTRY_CODES, player_id_lookup[year][:all])
			EVENTS << {:match_id => match_id, :type => "red"}.merge(vals)
		end	
	end
end

open("data/import/events.csv", 'w') { |f|	
	f.puts (["match_id", 
			 "player",
			 "player_id",
			 "time",
			 "type"]).join(",")

  	EVENTS.each do |event|
		f.puts ["\"#{event[:match_id]}\"",
		    	"\"#{event[:player]}\"",
		    	"\"#{event[:player_id]}\"",
				"#{event[:time]}",
				"\"#{event[:type]}\""
				].join(",") 
	end
}