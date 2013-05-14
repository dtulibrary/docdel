class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.string :email, :null => false
      t.string :callback_url, :null => false
      t.string :atitle
      t.string :aufirst
      t.string :aulast
      t.string :date
      t.timestamp :delivered_art
      t.string :doi
      t.string :eissn
      t.string :epage
      t.string :isbn
      t.string :issn
      t.string :issue
      t.string :pages
      t.string :spage
      t.string :title
      t.string :volume

      t.timestamps
    end
    add_index :orders, :email
  end
end
