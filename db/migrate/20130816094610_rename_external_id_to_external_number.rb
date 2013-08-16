class RenameExternalIdToExternalNumber < ActiveRecord::Migration
  def change
    rename_column :order_requests, :external_id, :external_number
  end
end
