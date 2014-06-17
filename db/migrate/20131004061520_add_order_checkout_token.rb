class AddOrderCheckoutToken < ActiveRecord::Migration
  def change
    add_column :orders, :paypal_checkout_token, :string
    add_index :orders, :paypal_checkout_token    
  end
end
