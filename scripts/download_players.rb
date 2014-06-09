require 'mechanize'
require 'parallel'

a = Mechanize.new { |agent|
  agent.user_agent_alias = 'Mac Safari'
}

all_players = File.readlines("data/players.csv").
                       map { |row| row.gsub(/\n/, "").split(",") }

Parallel.each(all_players.uniq, :in_threads=>8) do |to_download|
  year = to_download[0]
  team = to_download[1]
  link = to_download[-1]

  full_link = "http://www.fifa.com" + link
  puts "Processing #{full_link} "  

  player_id = full_link.split("/")[-2].split("=")[1]
  a.get(full_link).save_as  "data/players/#{year}-#{team}-#{player_id}.html"
end