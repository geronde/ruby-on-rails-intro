class CreateEvolutions < ActiveRecord::Migration[6.0]
  def up
    create_table :evolutions, :id => false do |t|
      t.string :id, :null => false
      t.string :name, :null => false
      t.timestamps
    end
  end
  def down
    drop_table :evolutions
  end
end
