class CreateOrderStatuses < ActiveRecord::Migration
  def change
    create_table :order_statuses do |t|
      t.string :code, :null => false

      t.timestamps
    end
    add_index :order_statuses, :code, :unique => true
  end
end
