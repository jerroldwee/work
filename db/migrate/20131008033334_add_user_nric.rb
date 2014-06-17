class AddUserNric < ActiveRecord::Migration
  def change
    add_column :users, :nric, :string
    add_index :users, :nric
  end
end
