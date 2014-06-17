class AddAttachmentUploadToFitRoomImages < ActiveRecord::Migration
  def self.up
    change_table :fit_room_images do |t|
      t.attachment :upload
    end
  end

  def self.down
    drop_attached_file :fit_room_images, :upload
  end
end
