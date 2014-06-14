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
end

