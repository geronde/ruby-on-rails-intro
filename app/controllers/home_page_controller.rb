class HomePageController < ApplicationController
  def index
    allPokemons = Pokemon.all
    @pokemons = allPokemons.map {|poke| {name: poke["name"]}}
    @title = 'Pokemons'
  end
end
