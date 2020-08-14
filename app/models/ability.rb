# frozen_string_literal: true

class Ability < ApplicationRecord
  has_and_belongs_to_many :pokemons, join_table: 'abilities_pokemons'
end
