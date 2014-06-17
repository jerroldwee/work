class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :title
      t.text :description
      t.decimal :price
      t.string :code
      t.string :product_type

      t.timestamps
    end
  end
end
