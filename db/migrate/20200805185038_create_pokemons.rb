class CreatePokemons < ActiveRecord::Migration[6.0]
  def up
    create_table :pokemons, :id => false do |t|
      t.string :id , :primary_key => true 
      t.string :name , :null => false
      t.timestamps
    end
  end
  def down
    drop_table :pokemons
  end
end
