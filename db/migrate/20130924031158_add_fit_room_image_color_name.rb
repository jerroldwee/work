class AddFitRoomImageColorName < ActiveRecord::Migration
  def change
    add_column :fit_room_images, :name, :string
  end
end
