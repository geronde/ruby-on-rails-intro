class CreateAbilities < ActiveRecord::Migration[6.0]
  def change
    create_table :abilities, :id => false do |t|
      t.string :id, :null => false
      t.string :name, :null => false
      t.timestamps
    end
  end
end
