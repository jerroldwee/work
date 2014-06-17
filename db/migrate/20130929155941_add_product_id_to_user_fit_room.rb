class AddProductIdToUserFitRoom < ActiveRecord::Migration
  def change
    add_column :user_fit_rooms, :product_id, :integer
    add_column :user_fit_rooms, :color_id, :integer
  end
end
