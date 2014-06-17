class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.string :no
      t.integer :billing_id
      t.string :address_line_1
      t.string :address_line_2
      t.string :address_line_3
      t.string :email
      t.string :payment_type
      t.boolean :paid
      t.string :payment_receipt
      t.string :transaction_id

      t.timestamps
    end
  end
end
