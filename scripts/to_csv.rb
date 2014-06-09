require "nokogiri"
require 'open-uri'
require 'date'

all_the_matches = File.readlines("data/matches.csv").
                       map { |row| row.gsub(/\n/, "").split(",") }

matches = {}

all_the_matches.each do |match|
	match_id = match[5].gsub(/\.html/, "").split("/")[-2].split("=")[1]
	matches[match_id] = {
		:match_number => match[-1],
		:year => match[0]
	}
end

match_files = Dir["data/matches/*"]

match_files.each do |match_file|
	match_id = match_file.gsub(/\.html/, "").split("/")[-1]

	@doc = Nokogiri::HTML(open(match_file))
	world_cup = @doc.css("div.content_header h1").text

	host = world_cup.match(/\d{4} FIFA World Cup (.*?) ?\u2122/)[1]

	if world_cup.start_with? "2010 FIFA World Cup South Africa"
		header = @doc.css("div.mh_header h1")
		home = header.css("a:nth-child(1)").text.strip
		away = header.css("a:nth-child(2)").text.strip
		h_score, a_score = @doc.css("#result").text.split(":")	
		phase = @doc.css("div.phase").text.strip

		columns = @doc.css("div.hdTeams div.cont table tbody tr")

		# match_number = @doc.css("div.mh_footer .matchdata").text.gsub(/Match /, "").strip
		date = @doc.css(".weatherico span:nth-child(1)").text.strip
		time = columns.css("td:nth-child(3)").text.strip
		stadium = @doc.css("div.mh_footer .location").text.strip
		attendance = columns.css("td:nth-child(5)").text.strip
	else
		home, away = @doc.css("div.teams").text.split("-").map(&:strip)
		h_score, a_score = @doc.css("div.result").text.match(/(\d{1,2}:\d{1,2})/)[1].split(":")	
		phase = @doc.css("div.phase").text.strip

		columns = @doc.css("div.hdTeams div.cont table tbody tr")

		if columns.css("td").count == 5
			match_number = columns.css("td:nth-child(1)").text.strip
			date = columns.css("td:nth-child(2)").text.strip
			time = columns.css("td:nth-child(3)").text.strip
			stadium = columns.css("td:nth-child(4)").text.strip
			attendance = columns.css("td:nth-child(5)").text.strip
		elsif columns.css("td").count == 4
			date = columns.css("td:nth-child(1)").text.strip
			time = columns.css("td:nth-child(2)").text.strip
			stadium = columns.css("td:nth-child(3)").text.strip
			attendance = columns.css("td:nth-child(4)").text.strip
		end
	end

	matches[match_id] = matches[match_id].merge( {:home => home, 
					     :host => host,
						 :away => away, 
						 :h_score => h_score,
						 :a_score => a_score,
						 :date => date,
						 :time => time,
						 :stadium => stadium,
						 :attendance => attendance,
						 :world_cup => world_cup,
						 :phase => phase
						})
end

matches.group_by { |match_id, match| match[:world_cup] }.each do | wc, rows |
	sorted = rows.sort_by { |id, item| DateTime.parse("#{item[:date]} #{item[:time]}") }

	sorted.each_with_index do |x, idx|
		id, item = x
		matches[id][:new_match_number] = idx + 1
	end
end

open("data/import/matches.csv", 'w') { |f|	
	f.puts (["world_cup",
		     "id", 
			 "home", 
			 "away", 
			 "h_score", 
			 "a_score",
			 "match_number",
			 "new_match_number",
			 "date",
			 "time",
			 "stadium",
			 "attendance",
			 "phase",
			 "year",
			 "host"]).join(",")

  	matches.each do |match_id, row|
		f.puts ["\"#{row[:world_cup]}\"",
			    "\"#{match_id}\"", 
				"\"#{row[:home]}\"", 
				"\"#{row[:away]}\"",
				"\"#{row[:h_score]}\"",
				"\"#{row[:a_score]}\"",
				"\"#{row[:match_number]}\"",
				"\"#{row[:new_match_number]}\"",
				"\"#{row[:date]}\"",
				"\"#{row[:time]}\"",
				"\"#{row[:stadium]}\"",
				"\"#{row[:attendance]}\"",
				"\"#{row[:phase]}\"",
				"#{row[:year]}",
				"\"#{row[:host]}\"",
				].join(",")
	end
}