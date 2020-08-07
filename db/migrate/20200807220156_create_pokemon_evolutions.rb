class CreatePokemonEvolutions < ActiveRecord::Migration[6.0]
  def up
    create_table :pokemon_evolutions do |t|
      t.string :pokemon_id
      t.string :type_id
      t.timestamps
    end
  end
  def down
    drop_table :pokemon_evolutions
  end
end
