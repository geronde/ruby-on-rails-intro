# frozen_string_literal: true

class Evolution < ApplicationRecord
  has_and_belongs_to_many :pokemons, join_table: 'evolutions_pokemons'
end
