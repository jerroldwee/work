class AddWallPostToFacebookFlag < ActiveRecord::Migration
  def change
    add_column :user_fit_rooms, :facebook_post_id, :string
    add_index :user_fit_rooms, :facebook_post_id
  end
end
