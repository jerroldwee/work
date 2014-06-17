class AddAttachmentUploadToProductImages < ActiveRecord::Migration
  def self.up
    add_column :product_images, :upload_file_name, :string
    add_column :product_images, :upload_content_type, :string
    add_column :product_images, :upload_file_size, :integer
    add_column :product_images, :upload_updated_at, :datetime
  end

  def self.down
    remove_column :product_images, :upload_file_name
    remove_column :product_images, :upload_content_type
    remove_column :product_images, :upload_file_size
    remove_column :product_images, :upload_updated_at
  end
end
