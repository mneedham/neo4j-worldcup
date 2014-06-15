require 'mechanize'
require 'parallel'

a = Mechanize.new { |agent|
  agent.user_agent_alias = 'Mac Safari'
}

all_the_matches = File.readlines("data/matches.csv").
                       map { |row| row.gsub(/\n/, "").split(",") }

Parallel.each(all_the_matches, :in_threads=>8) do |match|
  to_download = match[5]
  year = match[0]

  full_link = "http://www.fifa.com" + to_download 
  match_id = full_link.split("/")[9].split("=")[1]
  puts "Processing #{full_link} "  
  # a.get(full_link).save_as  "data/matches/#{match_id}.html"
  if year == "2010"
  	link = full_link.gsub(/index\.html/, "statistics.html")
  	a.get(link).save_as  "data/matches/stats/#{match_id}.html"
  end
end