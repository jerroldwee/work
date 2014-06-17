class CreateLineItems < ActiveRecord::Migration
  def change
    create_table :line_items do |t|
      t.integer :product_id
      t.integer :cart_id
      t.integer :order_id
      t.integer :quantity
      t.integer :order_id
      t.decimal :price
      t.timestamps
    end
    add_index "line_items", ["cart_id"], name: "index_line_items_on_cart_id"
    add_index "line_items", ["order_id"], name: "index_line_items_on_order_id"
    add_index "line_items", ["product_id"], name: "index_line_items_on_product_id"
  end
end
