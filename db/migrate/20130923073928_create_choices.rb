class CreateChoices < ActiveRecord::Migration
  def change
    create_table :choices do |t|
      t.integer :product_id
      t.integer :color_id
      t.integer :inventory_count
      t.timestamps
    end
  end
end
