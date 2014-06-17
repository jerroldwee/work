class CreateAttachments < ActiveRecord::Migration
  def change
    create_table :attachments do |t|
      t.string :guid
      t.timestamps
    end
    add_index :attachments, :guid
  end
end
