class CreateFitRoomImages < ActiveRecord::Migration
  def change
    create_table :fit_room_images do |t|
      t.integer :product_id
      t.integer :position

      t.timestamps
    end
  end
end
