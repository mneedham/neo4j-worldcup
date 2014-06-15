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

    it "removes squad number" do
        expect(Functions.clean_up_player("3 John HEITINGA (109')")).to eq("John Heitinga")
        expect(Functions.clean_up_player("(68') Jorge FUCILE 4")).to eq("Jorge Fucile")
        expect(Functions.clean_up_player(" (90'+3) Anther YAHIA 4  ")).to eq("Anther Yahia")
    end

    it "remove punctuation and extra spaces" do
        expect(Functions.clean_up_player(", Victor NDIP (CMR) 46'")).to eq("Victor Ndip")
    end

    it "detects multiple goals" do
        expect(Functions.multiple_goals?("Miroslav KLOSE (68' 89') ")).to eq(true)
        expect(Functions.multiple_goals?("Miroslav KLOSE (68')")).to eq(false)
    end
end
