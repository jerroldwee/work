class AddDiscountCreditToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :discount_credit, :integer
  end
end
