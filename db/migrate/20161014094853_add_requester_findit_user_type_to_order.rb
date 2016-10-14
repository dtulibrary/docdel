class AddRequesterFinditUserTypeToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :requester_findit_user_type, :string
  end
end
