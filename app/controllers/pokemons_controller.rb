require 'json'
class PokemonsController < ApplicationController
    layout false

    def index
        allPokemons = Pokemon.all
        @pokemons = allPokemons.map {|poke| {name: poke["name"]}}
        @title = 'Pokemons'
      end

    def show
        @pokemon = Pokemon.find(params[:id])

        pokemonAbility = PokemonAbility.where(pokemon_id: params[:id])
        pokemonEvolution = PokemonEvolution.where(pokemon_id: params[:id])
        pokemonType = PokemonType.where(pokemon_id: params[:id])
        
        
        abilityIds = pokemonAbility.map {|pab| pab[:ability_id] }
        evolutionIds = pokemonEvolution.map {|pab| pab[:evolution_id] }
        typeIds = pokemonType.map {|tp| tp[:type_id] }
        
        @abilities = Ability.find(abilityIds)
        @evolutions = Evolution.find(evolutionIds)
        @types = Type.find(typeIds)
        @title = @pokemon[:name]
    end

    def type
        selectedType = Type.find(params[:id])
        @title = selectedType[:name]
        pokemonType = PokemonType.where(type_id: params[:id])
        pokemonIds = pokemonType.map {|tp| tp[:pokemon_id] }

        @pokemons = Pokemon.find(pokemonIds)
        
    end
end
