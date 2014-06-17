class AddCreditRewardIndex < ActiveRecord::Migration
  def change
    add_index :credit_rewards, :user_id
  end
end
