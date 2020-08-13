require 'json'
require 'async'
require 'async/http/internet'

require File.expand_path('../../config/environment', __dir__)

module Pokeapi   
    def Pokeapi.fetch(url)
        data = {}
        Async do 
            internet = Async::HTTP::Internet.new
            response = internet.get(url)
            begin
                data = JSON.parse(response.read)
            rescue JSON::ParserError
                data = {}
            end
        ensure 
            internet.close    
        end
        return data
    end

    def Pokeapi.getId(str) 
        return str.split('/').slice(-1)
    end

    def Pokeapi.getPokemons()
        pokemons = Pokeapi.fetch('https://pokeapi.co/api/v2/pokemon?limit=2000&offset=0')
        formattedPokemons = pokemons["results"].map{|poke| {created_at:DateTime.now,updated_at:DateTime.now ,name: poke["name"], id: Pokeapi.getId(poke["url"])} }
        
        return formattedPokemons
    end

    
    def Pokeapi.getTypes()
        types = Pokeapi.fetch('https://pokeapi.co/api/v2/type')
        formatted = types["results"].map{|type| {created_at:DateTime.now,updated_at:DateTime.now, name: type["name"], id: Pokeapi.getId(type["url"])} }
    end
    
    def Pokeapi.getAbilities()
        abilities = Pokeapi.fetch('https://pokeapi.co/api/v2/ability?offset=0&limit=2000')
        formatted = abilities["results"].map{|type| {created_at:DateTime.now, updated_at:DateTime.now,name: type["name"], id: Pokeapi.getId(type["url"])} }
    end

    def Pokeapi.getEvolutions(id)
        chains = []

        data = Pokeapi.fetch("https://pokeapi.co/api/v2/evolution-chain/#{id}/")
        
        if data.empty? 
            return {} 
        end
        
        evolutionData = data["chain"]
        evolvesTo = evolutionData["evolves_to"]
    
        numberOfEvolutions = evolvesTo.length;            
        loop do 
            if numberOfEvolutions >= 1
                evolvesTo.each_with_index do |element,i|
                    chains.push({
                        name: evolutionData["evolves_to"][i]["species"]["name"],
                        id: Pokeapi.getId(evolutionData["evolves_to"][i]["species"]["url"])
                      });
                  end
                end

            chains.push({
                name: evolutionData["species"]["name"],
                id: Pokeapi.getId(evolutionData["species"]["url"])
                });

            
            break unless evolutionData.empty? && !evolutionData.has_key?("evolves_to")
        end
        return chains 
    end
    def Pokeapi.insertConfigData
        ActiveRecord::Base.transaction do
            Pokemon.insert_all(Pokeapi.getPokemons())
            Type.insert_all(Pokeapi.getTypes())
            Ability.insert_all(Pokeapi.getAbilities())
          end
    end
    def Pokeapi.insertEvolutions
        evolutions = []
        pokeEvolutions = []
        Pokemon.find_each do |pokemon|
            id = pokemon.id
            evo = Pokeapi.getEvolutions(pokemon.id)
            pokeEvo = evo.select {|val| !val.empty?}.map {|pe| {pokemon_id: id, evolution_id: pe[:id] } } 
            evolutions.push(evo)
            pokeEvolutions.push(pokeEvo)
        end
        data = evolutions.select {|evo| !evo.empty? }.flatten(1).map {|evol| {name: evol[:name], id: evol[:id], updated_at: DateTime.now ,created_at: DateTime.now} }
        Evolution.insert_all(data)
        PokemonEvolution.insert_all(pokeEvolutions.flatten(1))
    end

    def Pokeapi.insertPokemonTypeAndAbilities
        pokeTypes = []
        pokeAbilities= []
        Pokemon.find_each do |pokemon|
            id = pokemon.id
            pokemon = Pokeapi.fetch("https://pokeapi.co/api/v2/pokemon/#{id}")
            
            pokeType = pokemon["types"].map {|pt| {pokemon_id: id, type_id: getId(pt["type"]["url"]) } } 
            pokeAbility = pokemon["abilities"].map {|pa| {pokemon_id: id, ability_id: getId(pa["ability"]["url"]) }}
            
            pokeTypes.push(pokeType)
            pokeAbilities.push(pokeAbility) 
            
            Pokemon.where(id:id).update(picture: pokemon["sprites"]["front_default"])
        end
        ActiveRecord::Base.transaction do
            PokemonType.insert_all(pokeTypes.flatten(1))
            PokemonAbility.insert_all(pokeAbilities.flatten(1))
        end
    end
end
Pokeapi.getPokemons()
Pokeapi.insertConfigData();
Pokeapi.insertEvolutions();
Pokeapi.insertPokemonTypeAndAbilities()