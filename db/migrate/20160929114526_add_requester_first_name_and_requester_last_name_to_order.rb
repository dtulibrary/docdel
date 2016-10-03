class AddRequesterFirstNameAndRequesterLastNameToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :requester_first_name, :string
    add_column :orders, :requester_last_name, :string
  end
end
