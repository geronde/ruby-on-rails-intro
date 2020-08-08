class CreatePokemonTypes < ActiveRecord::Migration[6.0]
  def up
    create_join_table :pokemons, :types do |t|
      t.index :pokemon_id
      t.index :type_id
    end
  end
  def down
    drop_table :pokemons_types
  end
end
