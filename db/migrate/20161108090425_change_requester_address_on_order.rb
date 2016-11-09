class ChangeRequesterAddressOnOrder < ActiveRecord::Migration
  def up
    change_column :orders, :requester_address, :string, :limit => 1024
  end

  def down
    change_column :orders, :requester_address, :string, :limit => 255
  end
end
