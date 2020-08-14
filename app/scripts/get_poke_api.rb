# frozen_string_literal: true

# rubocop:disable Metrics/ModuleLength

require 'json'
require 'async'
require 'async/http/internet'

require File.expand_path('../../config/environment', __dir__)

# PokeApi module to extract pokemon data and insert in database
module Pokeapi
  def self.fetch(url)
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
    data
  end

  def self.get_id(str)
    str.split('/').slice(-1)
  end

  def self.fetch_pokemons
    pokemons = Pokeapi.fetch('https://pokeapi.co/api/v2/pokemon?limit=2000&offset=0')
    pokemons['results'].map do |poke|
      { created_at: DateTime.now,
        updated_at: DateTime.now,
        name: poke['name'],
        id: Pokeapi.get_id(poke['url']) }
    end
  end

  def self.fetch_types
    types = Pokeapi.fetch('https://pokeapi.co/api/v2/type')
    types['results'].map do |type|
      { created_at: DateTime.now,
        updated_at: DateTime.now,
        name: type['name'],
        id: Pokeapi.get_Id(type['url']) }
    end
  end

  def self.fetch_abilities
    abilities = Pokeapi.fetch('https://pokeapi.co/api/v2/ability?offset=0&limit=2000')
    abilities['results'].map do |type|
      {
        created_at: DateTime.now,
        updated_at: DateTime.now,
        name: type['name'],
        id: Pokeapi.get_id(type['url'])
      }
    end
  end

  def self.format_evolutions(id)
    chains = []

    data = Pokeapi.fetch("https://pokeapi.co/api/v2/evolution-chain/#{id}/")

    return {} if data.empty?

    evolution_data = data['chain']
    evolves_to = evolution_data['evolves_to']

    number_of_evolutions = evolves_to.length
    loop do
      if number_of_evolutions >= 1
        evolvesTo.each_with_index do |_element, i|
          chains.push({
                        name: evolution_data['evolves_to'][i]['species']['name'],
                        id: Pokeapi.get_id(evolution_data['evolves_to'][i]['species']['url'])
                      })
        end
      end

      chains.push({
                    name: evolution_data['species']['name'],
                    id: Pokeapi.get_id(evolution_data['species']['url'])
                  })

      break unless evolution_data.empty? && !evolution_data.key?('evolves_to')
    end
    chains
  end

  def self.insert_config_data
    ActiveRecord::Base.transaction do
      Pokemon.insert_all(Pokeapi.fetch_pokemons)
      Type.insert_all(Pokeapi.fetch_types)
      Ability.insert_all(Pokeapi.fetch_abilities)
    end
  end

  def self.insert_evolutions
    evolutions = []
    poke_evolutions = []
    Pokemon.find_each do |pokemon|
      id = pokemon.id
      evo = Pokeapi.fetch_evolutions(pokemon.id)
      poke_evo = evo.reject(&:empty?).map { |pe| { pokemon_id: id, evolution_id: pe[:id] } }
      evolutions.push(evo)
      poke_evolutions.push(poke_evo)
    end
    data = evolutions.reject(&:empty?).flatten(1).map do |evol|
      { name: evol[:name],
        id: evol[:id],
        updated_at: DateTime.now,
        created_at: DateTime.now }
    end
    Evolution.insert_all(data)
    PokemonEvolution.insert_all(pokeEvolutions.flatten(1))
  end

  def self.insert_types_and_abilities
    poke_types = []
    poke_abilities = []
    Pokemon.find_each do |pokemon|
      id = pokemon.id
      pokemon = Pokeapi.fetch("https://pokeapi.co/api/v2/pokemon/#{id}")

      poke_type = pokemon['types'].map do |pt|
        { pokemon_id: id,
          type_id: getId(pt['type']['url']) }
      end
      poke_ability = pokemon['abilities'].map do |pa|
        { pokemon_id: id,
          ability_id: getId(pa['ability']['url']) }
      end

      poke_types.push(poke_type)
      poke_abilities.push(poke_ability)

      Pokemon.where(id: id).update(picture: pokemon['sprites']['front_default'])
    end
    ActiveRecord::Base.transaction do
      PokemonType.insert_all(poke_types.flatten(1))
      PokemonAbility.insert_all(poke_abilities.flatten(1))
    end
  end
end

Pokeapi.fetch_pokemons
Pokeapi.insert_config_data
Pokeapi.insert_evolutions
Pokeapi.insert_types_and_abilities
