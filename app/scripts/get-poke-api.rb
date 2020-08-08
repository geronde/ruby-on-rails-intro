require 'json'
require 'async'
require 'async/http/internet'
require 'active_record'

module Pokeapi
    def Pokeapi.fetch(url)
        data = {}
        Async do 
            internet = Async::HTTP::Internet.new
            response = internet.get(url)
            data = JSON.parse(response.read)    
        ensure 
            internet.close    
        end
        return data
    end

    def Pokeapi.getId(str) 
        return str.split('/').slice(-1)
    end

    def Pokeapi.getPokemons()
        pokemons = Pokeapi.fetch('https://pokeapi.co/api/v2/pokemon?limit=1000&offset=200')
        formatted = pokemons["results"].map{|poke| {name: poke["name"], id: Pokeapi.getId(poke["url"])} }
    end

    
    def Pokeapi.getTypes()
        types = Pokeapi.fetch('https://pokeapi.co/api/v2/type')
        formatted = types["results"].map{|type| {name: type["name"], id: Pokeapi.getId(type["url"])} }
    end
    
    def Pokeapi.getAbilities()
        abilities = Pokeapi.fetch('https://pokeapi.co/api/v2/ability?offset=20&limit=1000')
        formatted = abilities["results"].map{|type| {name: type["name"], id: Pokeapi.getId(type["url"])} }
    end
    def Pokeapi.getEvolutions(id) 
        chains = []
        data = Pokeapi.fetch("https://pokeapi.co/api/v2/evolution-chain/#{id}/")
        evolvesTo = data["chain"]["evolves_to"]
        loop do 
            numberOfEvolutions = evolvesTo.length;

            print numberOfEvolutions
            
            chains.push({
              speciesName: data["chain"]["species"]["name"]
            });
      
            if numberOfEvolutions > 1
                evolvesTo.each_with_index do |element,i|
                    chains.push({
                        speciesName: chains["evolves_to"][i]["species"]["name"],
                      });
                  end
                end
      
            data["chain"] = data["chain"]["evolves_to"][0];
            
            break if data["chain"] == nil && data["chain"].has_key?("evolves_to")
        end
        retrun chains 
    end
end
