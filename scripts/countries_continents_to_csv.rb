require 'csv'

continents = {"Africa" => "africa.txt", 
			  "Asia" => "asia.txt",
			  "Europe" => "europe.txt",
			  "North America" => "north_america.txt",
			  "Oceania" => "oceania.txt",
			  "South America" => "south_america.txt"}

result = []
continents.each do |continent, file|
	CSV.foreach("data/country/#{file}", :headers => false) do |row|		
		result << [row[0], continent]
	end
end

CSV.open("data/import/country_continents.csv", "wb", :force_quotes => true) do |csv|
  csv << ["country", "continent"]
  result.each do |row|
  	csv << row
  end
end