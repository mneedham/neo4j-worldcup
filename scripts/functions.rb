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

        player_lookup[key][:all] ||= {}        
        player_lookup[key][:all][value['player_name']] = value['player_id']
      end 
    end
    player_lookup 
  end

  def self.clean_up_player(player)
  	 player = player.strip

  	 player = player.gsub(/É/, "é").gsub(/Á/, "á").gsub(/^\d{1,2}/, "").strip

     if player.start_with? ","
        player = player.gsub(/,/, "").strip
     end

  	 if player.start_with? "("
        player = player.match(/\(\d{1,3}'[\+\d]{0,3}\)([^\(]+) \(?.*/)[1]
     elsif player.include? "("
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
      time = scorer.match(/(\d{1,3})'/)
      time ? time[1] : nil
    end
  	
  end  

  def self.process_scorer(scorer, country_codes, player_id_lookup)
  	# p scorer
  	player = clean_up_player(scorer)
    player_id = player_id_lookup[player]

  	type = "goal"
  	type = "owngoal" if scorer.include?("Own goal") || scorer.include?("OG")
  	type = "penalty" if scorer.include?("Penalty goal") || scorer.include?("PEN")

  	{ :player => player, 
      :player_id => player_id,
  	  :time => extract_time(scorer).to_i,
  	  :type => type
  	}
  end

  def self.process_card(scorer, country_codes, player_id_lookup)
    player = clean_up_player(scorer)
    player_id = player_id_lookup[player]

    { :player => player, 
      :player_id => player_id,
      :time => extract_time(scorer).to_i      
    }
  end  
end

