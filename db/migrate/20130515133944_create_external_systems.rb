class CreateExternalSystems < ActiveRecord::Migration
  def change
    create_table :external_systems do |t|
      t.string :code, :null => false

      t.timestamps
    end
    add_index :external_systems, :code, :unique => true
  end
end
