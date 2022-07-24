class CreateVideo < ActiveRecord::Migration[6.1]
  def change
    create_table :videos, id: false do |t|
      t.string :cid, null: false, primary_key: true
      t.string :title
      t.string :sales_info
      t.string :additional_info
      t.integer :price_4k
      t.integer :price_hd
      t.integer :price_dl
      t.integer :price_st
      t.timestamps
    end
  end
end
