class AddPaypalOrderDetails < ActiveRecord::Migration
  def change
    add_column :orders, :paypal_email, :string
    add_column :orders, :paypal_customer_token, :string
    add_column :orders, :paypal_payment_transaction_id, :string
  end
end
