class ChangeExternalNumberToText < ActiveRecord::Migration
  def up
    change_column :order_requests, :external_number, :text
  end

  def down
  end
end
