class AddEmailToBillingAddresses < ActiveRecord::Migration
  def change
    add_column :billing_addresses, :email, :string
  end
end
