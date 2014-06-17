class AddAttachmentUploadToPromotions < ActiveRecord::Migration
  def self.up
    change_table :promotions do |t|
      t.attachment :upload
    end
  end

  def self.down
    drop_attached_file :promotions, :upload
  end
end
