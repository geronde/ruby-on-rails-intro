class CreatePokemons < ActiveRecord::Migration[6.0]
  def change
    create_table :pokemons, :id => false do |t|
      t.string :id , :primary_key => true 
      t.string :name , :null => false
      t.timestamps
    end
  end
end
