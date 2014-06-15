require "nokogiri"
require 'open-uri'
require 'date'
require_relative 'functions.rb'

COUNTRY_CODES = {}
cc = File.readlines("data/cc.csv").
                       map { |row| row.gsub(/\n/, "").split(",") }

cc.each {|k, v| COUNTRY_CODES[k] = v.strip }

all_the_matches = File.readlines("data/matches.csv").
                       map { |row| row.gsub(/\n/, "").split(",") }

EVENTS = []

match_files = Dir["data/matches/*"]

match_files.select {|file| !file.end_with? ".md" }.each do |match_file|
	match_id = match_file.gsub(/\.html/, "").split("/")[-1]
	puts match_id
	
	@doc = Nokogiri::HTML(open(match_file))
	world_cup = @doc.css("div.content_header h1").text

	scorers = @doc.css("div.cont:nth-child(4) li")

	scorers.each do |scorer|
		EVENTS << {:match_id => match_id}.merge(Functions.process_scorer(scorer.text, COUNTRY_CODES))
	end	

	yellows = @doc.css("div.cont:nth-child(6) li")

	yellows.each do |scorer|
		EVENTS << {:match_id => match_id, :type => "yellow"}.merge(Functions.process_card(scorer.text, COUNTRY_CODES))
	end

	reds = @doc.css("div.cont:nth-child(7) li")

	reds.each do |scorer|
		EVENTS << {:match_id => match_id, :type => "red"}.merge(Functions.process_card(scorer.text, COUNTRY_CODES))
	end	

end

open("data/import/events.csv", 'w') { |f|	
	f.puts (["match_id", 
			 "player",
			 "team",
			 "time",
			 "type"]).join(",")

  	EVENTS.each do |event|
		f.puts ["\"#{event[:match_id]}\"",
		    	"\"#{event[:player]}\"",
		   		"\"#{event[:for]}\"" ,
				"#{event[:time]}",
				"\"#{event[:type]}\""
				].join(",") 
	end
}