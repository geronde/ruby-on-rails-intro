class CreateAbilities < ActiveRecord::Migration[6.0]
  def up
    create_table :abilities, :id => false do |t|
      t.string :id, :null => false
      t.string :name, :null => false
      t.timestamps
    end
  end
  def down
    drop_table :abilities
  end
end
