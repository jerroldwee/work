class AddAttachmentTargetImageToUserFitRooms < ActiveRecord::Migration
  def self.up
    change_table :user_fit_rooms do |t|
      t.attachment :target_image
    end
  end

  def self.down
    drop_attached_file :user_fit_rooms, :target_image
  end
end
