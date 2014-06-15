#encoding: UTF-8
require 'csv'

module Functions  
  def self.player_id_lookup()
    players = []
    CSV.foreach("data/import/players_with_dups.csv", :headers => true, :encoding => "UTF-8") do |row|
      players << row
    end

    player_lookup = {}
    players.group_by { |x| x["year"]}.each do |key, values|
      player_lookup[key] ||= {}

      values.each do |value|    
        player_lookup[key][value['team']] ||= {}
        player_lookup[key][value['team']][value['player_name']] = value['player_id']
      end 
    end
    player_lookup 
  end

  def self.clean_up_player(player)
  	 player = player.strip

  	 player = player.gsub(/É/, "é").gsub(/Á/, "á")

  	 if player.include? "("
  	 	player = player.match(/([^\(]+) \(?.*/)[1]
  	 end  

  	 player.split(" ").map(&:capitalize).join(" ")
  end

  def self.extract_country_code(scorer)
  	scorer.match(/\(([A-Z]{3})\)/)[1]
  end

  def self.extract_time(scorer)
    if scorer.include? "PSO"
      120
    else
      scorer.match(/(\d{1,3})'/)[1]  
    end
  	
  end  

  def self.process_scorer(scorer, country_codes)
  	# p scorer
  	player = clean_up_player(scorer)

  	type = "goal"
  	type = "owngoal" if scorer.include?("Own goal") || scorer.include?("OG")
  	type = "penalty" if scorer.include?("Penalty goal") || scorer.include?("PEN")

  	{ :player => player, 
  	  :time => extract_time(scorer).to_i,
  	  :type => type
  	}
  end

  def self.process_card(scorer, country_codes)
    player = clean_up_player(scorer)

    { :player => player, 
      :time => extract_time(scorer).to_i
    }
  end  
end

