class CreateUserFitRooms < ActiveRecord::Migration
  def change
    create_table :user_fit_rooms do |t|
      t.float :left
      t.float :top
      t.float :width
      t.float :height
      t.float :rotation
      t.boolean :temprary

      t.timestamps
    end
  end
end
