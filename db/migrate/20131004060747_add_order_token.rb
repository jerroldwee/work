class AddOrderToken < ActiveRecord::Migration
  def change
    add_column :orders, :checkout_token, :string
    add_index :orders, :checkout_token
  end
end
