class CreatePokemonAbilities < ActiveRecord::Migration[6.0]
  def up
    create_table :pokemon_abilities do |t|
      t.string :pokemon_id
      t.string :ability_id
      t.timestamps
    end
  end
  def down
    drop_table :pokemon_abilities
  end
end
