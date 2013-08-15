class AddCustomerOrderNumberToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :customer_order_number, :string
  end
end
