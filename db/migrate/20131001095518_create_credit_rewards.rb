class CreateCreditRewards < ActiveRecord::Migration
  def change
    create_table :credit_rewards do |t|
      t.integer :user_id
      t.string :description
      t.integer :total
      t.string :reward_type

      t.timestamps
    end
  end
end
