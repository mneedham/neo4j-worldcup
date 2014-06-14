#encoding: UTF-8
require_relative '../scripts/functions.rb'

describe "#Functions" do
    it "capitalises a player properly" do
        expect(Functions.clean_up_player("CRISTIANO RONALDO")).to eq("Cristiano Ronaldo")
    end

    it "removes brackets from a player's name to simplify things" do
    	expect(Functions.clean_up_player("Pele (edson Arantes Do Nascimento)")).to eq("Pele")
    	expect(Functions.clean_up_player("Pele Great (edson Arantes Do Nascimento)")).to eq("Pele Great")
    	expect(Functions.clean_up_player("Gilmar (gilmar Dos Santos Neves)")).to eq("Gilmar")    	
    end

    it "lower cases any weird characters" do 
    	expect(Functions.clean_up_player("PelÉ (edson Arantes Do Nascimento)")).to eq("Pelé")
    	expect(Functions.clean_up_player("RomÁrio")).to eq("Romário")
    end
end