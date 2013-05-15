class CreateOrderRequests < ActiveRecord::Migration
  def change
    create_table :order_requests do |t|
      t.references :order, :null => false
      t.references :order_status, :null => false
      t.references :external_system, :null => false
      t.float :external_copyright_charge
      t.string :external_currency
      t.integer :external_id
      t.float :external_service_charge
      t.string :external_url
      t.string :shelfmark

      t.timestamps
    end
    add_index :order_requests, :order_id
    add_index :order_requests, :order_status_id
    add_index :order_requests, :external_system_id
  end
end
