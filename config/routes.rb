Rails.application.routes.draw do
  get 'home_page/index'

  resources :pokemons 

  root 'home_page#index'
end
