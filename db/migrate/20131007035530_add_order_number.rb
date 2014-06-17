class AddOrderNumber < ActiveRecord::Migration
  def change
    add_column :orders, :order_number, :string
    Order.where("NOT(paypal_email IS NULL)").all.each{|o|o.add_order_number; o.save}
  end
end
