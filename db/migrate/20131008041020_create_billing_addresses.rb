class CreateBillingAddresses < ActiveRecord::Migration
  def change
    create_table :billing_addresses do |t|
      t.string   "address_line_1"
      t.string   "address_line_2"
      t.string   "address_line_3"
      t.string   "region"
      t.string   "state"
      t.string   "postal_code"
      t.string   "contact_no"
      t.string   "full_name"
      t.integer  "user_id"
      t.string   "country"
      t.string   "email"
      t.timestamps
    end
    add_index :billing_addresses, :user_id
  end
end
