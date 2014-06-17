class AddAttachmentPhotoToUserFitRooms < ActiveRecord::Migration
  def self.up
    change_table :user_fit_rooms do |t|
      t.attachment :photo
    end
  end

  def self.down
    drop_attached_file :user_fit_rooms, :photo
  end
end
