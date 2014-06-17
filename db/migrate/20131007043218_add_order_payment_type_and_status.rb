class AddOrderPaymentTypeAndStatus < ActiveRecord::Migration
  def change
    add_column :orders, :order_status, :string
    add_column :orders, :admin_remark, :text
    add_column :orders, :user_remark, :text

    Order.where("paypal_checkout_token = ?", "Cash").all.each{|o|o.paypal_checkout_token = nil; o.payment_type = "Cash"; o.save}
    Order.where("NOT(paypal_checkout_token IS NULL)").all.each{|o|o.payment_type = "Paypal"; o.save}
  end
end
