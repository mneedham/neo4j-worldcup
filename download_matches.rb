require 'mechanize'
require 'parallel'

a = Mechanize.new { |agent|
  agent.user_agent_alias = 'Mac Safari'
}

all_the_matches = File.readlines("data/matches.csv").
                       map { |row| row.gsub(/\n/, "").split(",") }

urls = all_the_matches
        .map {|match| match[5] }
        .uniq

Parallel.each(urls, :in_threads=>8) do |to_download|
	# http://www.fifa.com/tournaments/archive/worldcup/uruguay1930/matches/round=201/match=1089/index.html
  full_link = "http://www.fifa.com" + to_download
  match_id = full_link.split("/")[9].split("=")[1]
  puts "Processing #{full_link} "  
  a.get(full_link).save_as  "data/matches/#{match_id}.html"
end