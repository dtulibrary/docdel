class OrdersAddTypeAndInstitute < ActiveRecord::Migration
  def change
    add_column :orders, :institute_id, :integer
    add_column :orders, :user_type_id, :integer

    add_index :orders, :institute_id
    add_index :orders, :user_type_id
  end
end
