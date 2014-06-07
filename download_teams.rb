require 'mechanize'
require 'parallel'

a = Mechanize.new { |agent|
  agent.user_agent_alias = 'Mac Safari'
}

all_the_matches = File.readlines("data/matches.csv").
                       map { |row| row.gsub(/\n/, "").split(",") }

urls = all_the_matches
        .flat_map {|match| [[match[0], match[1], match[2]], 
                            [match[0], match[3], match[4]]] }
        .uniq

Parallel.each(urls, :in_threads=>8) do |to_download|
  year, team, link = to_download
  full_link = "http://www.fifa.com" + link
  puts "Processing #{full_link} "  
  a.get(full_link).save_as  "data/teams/#{year}-#{team}.html"
end