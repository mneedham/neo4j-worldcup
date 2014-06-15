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

SCORERS = []

match_files = Dir["data/matches/*"]

match_files.select {|file| !file.end_with? ".md" }.each do |match_file|
	match_id = match_file.gsub(/\.html/, "").split("/")[-1]
	puts match_id
	
	@doc = Nokogiri::HTML(open(match_file))
	world_cup = @doc.css("div.content_header h1").text

	scorers = @doc.css("div.cont:nth-child(4) li")

	scorers.each do |scorer|
		SCORERS << {:match_id => match_id}.merge(Functions.process_scorer(scorer.text, COUNTRY_CODES))
	end	
end

open("data/import/events.csv", 'w') { |f|	
	f.puts (["match_id", 
			 "player",
			 "team",
			 "time",
			 "type"]).join(",")

  	SCORERS.each do |scorer|
		f.puts ["\"#{scorer[:match_id]}\"",
		    	"\"#{scorer[:player]}\"",
		   		"\"#{scorer[:for]}\"" ,
				"#{scorer[:time]}",
				"\"#{scorer[:type]}\""
				].join(",") 
	end
}