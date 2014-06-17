class AddUserFitRoomTitle < ActiveRecord::Migration
  def change
    add_column :user_fit_rooms, :title, :string
  end
end
