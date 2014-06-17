class CreateProductImages < ActiveRecord::Migration
  def change
    create_table :product_images do |t|
      t.integer :choice_id
      t.integer :product_id
      t.integer :position

      t.timestamps
    end
  end
end
