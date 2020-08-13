Rails.application.routes.draw do
  root 'pokemons#index'

  match ':controller(/:action(/:id))', :via => :get
end
