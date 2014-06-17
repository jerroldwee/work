class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :provider
      t.string :uid
      t.string :name
      t.string :oauth_token
      t.datetime :oauth_expires_at
      t.string :email
      t.string :password_hash
      t.string :password_salt
      t.string :full_name
      t.string :contact_no
      t.string :api_key
      t.string :password_reset_token
      t.datetime :password_reset_sent_as

      t.timestamps
    end
  end
end
