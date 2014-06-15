#encoding: UTF-8

module Functions  
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
  	country = country_codes[extract_country_code(scorer)]

  	type = "goal"
  	type = "owngoal" if scorer.include? "Own goal"
  	type = "penalty" if scorer.include? "Penalty goal" 

  	{ :player => player, 
  	  :for => country, 
  	  :time => extract_time(scorer).to_i,
  	  :type => type
  	}
  end

  def self.process_card(scorer, country_codes)
    player = clean_up_player(scorer)
    country = country_codes[extract_country_code(scorer)]

    { :player => player, 
      :for => country, 
      :time => extract_time(scorer).to_i
    }
  end  
end

