class CreateBillings < ActiveRecord::Migration
  def change
    create_table :billings do |t|
      t.string :address_line_1
      t.string :address_line2
      t.string :address_line_3
      t.string :region
      t.string :state
      t.string :postal_code
      t.string :billing_contact_no
      t.string :billing_name
      t.string :country
      t.string :email

      t.timestamps
    end
  end
end
