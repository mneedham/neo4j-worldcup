require "nokogiri"
require 'open-uri'

world_cups = {
	2010 => "http://www.fifa.com/tournaments/archive/worldcup/southafrica2010/matches/",
	2006 => "http://www.fifa.com/tournaments/archive/worldcup/germany2006/matches",
	2002 => "http://www.fifa.com/tournaments/archive/worldcup/koreajapan2002/matches",
	1998 => "http://www.fifa.com/tournaments/archive/worldcup/france1998/matches",
	1994 => "http://www.fifa.com/tournaments/archive/worldcup/usa1994/matches",
	1990 => "http://www.fifa.com/tournaments/archive/worldcup/italy1990/matches",
	1986 => "http://www.fifa.com/tournaments/archive/worldcup/mexico1986/matches",
	1982 => "http://www.fifa.com/tournaments/archive/worldcup/spain1982/matches",
	1978 => "http://www.fifa.com/tournaments/archive/worldcup/argentina1978/matches",
	1974 => "http://www.fifa.com/tournaments/archive/worldcup/germany1974/matches",
	1970 => "http://www.fifa.com/tournaments/archive/worldcup/mexico1970/matches",
	1966 => "http://www.fifa.com/tournaments/archive/worldcup/england1966/matches",
	1962 => "http://www.fifa.com/tournaments/archive/worldcup/chile1962/matches",
	1958 => "http://www.fifa.com/tournaments/archive/worldcup/sweden1958/matches",
	1954 => "http://www.fifa.com/tournaments/archive/worldcup/switzerland1954/matches",
	1950 => "http://www.fifa.com/tournaments/archive/worldcup/brazil1950/matches",
	1938 => "http://www.fifa.com/tournaments/archive/worldcup/france1938/matches",
	1934 => "http://www.fifa.com/tournaments/archive/worldcup/italy1934/matches",
	1930 => "http://www.fifa.com/tournaments/archive/worldcup/uruguay1930/matches"

}

world_cups.each do |year, download_link|
	@doc = Nokogiri::HTML(open(download_link))

	matches = @doc.css("table.fixture tbody tr")

	matches.each do |match|
		venue = match.css(".v").text
		home = match.css(".homeTeam a").text
		home_link = match.css(".homeTeam a").attr("href").value
		away = match.css(".awayTeam a").text
		away_link = match.css(".awayTeam a").attr("href").value
		link = match.css("td:nth-child(6) a").attr("href").value
		result = match.css(".c a").text.strip

		puts "#{year},#{home},#{home_link},#{away},#{away_link},#{link},#{result},#{venue}"
	end
end

