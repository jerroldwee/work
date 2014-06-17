class AddAttachmentGuidToLineItem < ActiveRecord::Migration
  def change
    add_column :line_items, :attachment_guid, :string
    add_index :line_items, :attachment_guid
  end
end
