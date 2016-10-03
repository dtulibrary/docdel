class AddRequesterAddressToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :requester_address, :string
  end
end
