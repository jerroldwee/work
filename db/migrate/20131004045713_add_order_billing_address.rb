class AddOrderBillingAddress < ActiveRecord::Migration
  def change
   # add_column :orders, :full_name, :string
  #  add_column :orders, :state, :string
  #  add_column :orders, :region, :string
 #   add_column :orders, :country, :string
  #  add_column :orders, :contact_no, :string
 #   add_column :orders, :postal_code, :string
  #  add_column :orders, :email, :string
    add_column :orders, :delivery_type, :string
    add_column :billings, :address_line_2, :string
  end
end
