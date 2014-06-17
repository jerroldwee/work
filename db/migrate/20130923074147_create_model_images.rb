class CreateModelImages < ActiveRecord::Migration
  def change
    create_table :model_images do |t|
      t.string :type
      t.integer :product_id
      t.integer :position

      t.timestamps
    end
  end
end
