class OrderRequestAddReasonIdIndex < ActiveRecord::Migration
  def up
    add_index :order_requests, :reason_id
  end

  def down
    remove_index :order_requests, :reason_id
  end
end
