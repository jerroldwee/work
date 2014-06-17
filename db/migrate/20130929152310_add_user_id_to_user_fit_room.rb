class AddUserIdToUserFitRoom < ActiveRecord::Migration
  def change
    add_column :user_fit_rooms, :user_id, :integer
    add_index :user_fit_rooms, :user_id
  end
end
