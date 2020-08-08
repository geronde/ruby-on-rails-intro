class CreatePokemonAbilities < ActiveRecord::Migration[6.0]
  def up
    create_join_table :pokemons, :abilities do |t|
      t.index :pokemon_id
      t.index :ability_id
    end
  end
  def down
    drop_table :abilities_pokemons
  end
end
