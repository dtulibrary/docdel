class CreateReasons < ActiveRecord::Migration
  def change
    create_table :reasons do |t|
      t.string :code, :null => false

      t.timestamps
    end
    add_index :reasons, :code, :unique => true
  end
end
