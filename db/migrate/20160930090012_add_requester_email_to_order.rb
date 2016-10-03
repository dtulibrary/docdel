class AddRequesterEmailToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :requester_email, :string
  end
end
