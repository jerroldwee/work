class AddProductGender < ActiveRecord::Migration
  def change
    add_column :products, :gender, :string
    add_index :products, :gender
  end
end
