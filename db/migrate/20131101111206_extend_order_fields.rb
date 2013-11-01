class ExtendOrderFields < ActiveRecord::Migration
  def up
    change_column :orders, :atitle, :string, :limit => 1024
    change_column :orders, :title, :string, :limit => 1024
  end

  def down
  end
end
