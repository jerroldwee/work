class CreatePrescriptions < ActiveRecord::Migration
  def change
    create_table :prescriptions do |t|
      t.integer :user_id
      t.text :info
      t.string :title

      t.timestamps
    end
  end
end
