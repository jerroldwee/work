class CreateInvitationRecords < ActiveRecord::Migration
  def change
    create_table :invitation_records do |t|
      t.string :from_uid
      t.string :to_uid

      t.timestamps
    end
    add_index :invitation_records, :to_uid
    add_index :invitation_records, :from_uid
  end
end
