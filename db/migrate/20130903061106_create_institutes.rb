class CreateInstitutes < ActiveRecord::Migration
  def change
    create_table :institutes do |t|
      t.string :code, null: false

      t.timestamps
    end
  end
end
