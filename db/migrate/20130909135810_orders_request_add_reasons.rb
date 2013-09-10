class OrdersRequestAddReasons < ActiveRecord::Migration
  def up
    add_column :order_requests, :reason_id, :integer
    add_column :order_requests, :reason_text, :string
  end

  def down
   remove_column :order_requests, :reason_id
   remove_column :order_requests, :reason_text
  end
end
