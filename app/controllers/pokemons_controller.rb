# frozen_string_literal: true

class PokemonsController < ApplicationController
  layout false

  def index
    @pokemons = Pokemon.order(:name).page(params[:page])
    @title = 'Pokemons'
  end

  def show
    @pokemon = Pokemon.find(params[:id])

    pokemon_ability = PokemonAbility.where(pokemon_id: params[:id])
    pokemon_evolution = PokemonEvolution.where(pokemon_id: params[:id])
    pokemon_type = PokemonType.where(pokemon_id: params[:id])

    ability_ids = pokemon_ability.map { |pab| pab[:ability_id] }
    evolution_ids = pokemon_evolution.map { |pab| pab[:evolution_id] }
    type_ids = pokemon_type.map { |tp| tp[:type_id] }

    @abilities = Ability.find(ability_ids)
    @evolutions = Evolution.find(evolution_ids)
    @types = Type.find(type_ids)
    @title = @pokemon[:name]
  end

  def type
    selected_type = Type.find(params[:id])
    @title = selected_type[:name]
    pokemon_type = PokemonType.where(type_id: params[:id])
    pokemon_ids = pokemon_type.map { |tp| tp[:pokemon_id] }

    @pokemons = Pokemon.where(id: pokemon_ids).order(:name).page(params[:page])
  end
end
