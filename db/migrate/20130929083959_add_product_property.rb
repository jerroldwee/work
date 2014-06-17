class AddProductProperty < ActiveRecord::Migration
  def change
    add_column :products, :material_id, :integer
    add_column :products, :frame_shape_id, :integer
    add_column :products, :frame_width_id, :integer
    add_index :products, :material_id
    add_index :products, :frame_shape_id
    add_index :products, :frame_width_id
  end
end
