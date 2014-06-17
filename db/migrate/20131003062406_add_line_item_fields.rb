class AddLineItemFields < ActiveRecord::Migration
  def change
    add_column :line_items, :color_id, :integer
    add_column :line_items, :lens_id, :integer
    add_column :line_items, :amount, :float
    add_column :line_items, :info, :text
  end
end
