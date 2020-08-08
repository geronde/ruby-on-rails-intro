class CreatePokemonEvolutions < ActiveRecord::Migration[6.0]
  def up
    create_join_table :pokemons, :evolutions do |t|
      t.index :pokemon_id
      t.index :evolution_id
    end
  end
  def down
    drop_table :evolutions_pokemons
  end
end
