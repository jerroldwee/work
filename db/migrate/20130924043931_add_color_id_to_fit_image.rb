class AddColorIdToFitImage < ActiveRecord::Migration
  def change
    add_column :fit_room_images, :color_id, :integer
  end
end
