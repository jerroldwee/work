class AddDeliveryTrackingUrl < ActiveRecord::Migration
  def change
    add_column :orders, :delivery_tracking_url, :string
  end
end
