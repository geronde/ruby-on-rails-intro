class AddPicture < ActiveRecord::Migration[6.0]
  def change
    add_column :pokemons, :picture, :string
  end
  def down
    drop_column :pokemons, :picture
  end
end
