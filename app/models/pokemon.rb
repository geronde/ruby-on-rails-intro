# frozen_string_literal: true

class Pokemon < ApplicationRecord
  has_and_belongs_to_many :abilities, join_table: 'abilities_pokemons'
  has_and_belongs_to_many :evoltuions, join_table: 'evolutions_pokemons'
  has_and_belongs_to_many :types, join_table: 'pokemons_types'
end
