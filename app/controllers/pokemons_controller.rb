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

        abilityIds = pokemonAbility.map {|pab| pab[:ability_id] }
        evolutionIds = pokemonEvolution.map {|pab| pab[:evolution_id] }
        
        @abilities = Ability.find(abilityIds)
        @evolutions = Evolution.find(evolutionIds)
        @title = @pokemon[:name]
    end
end
