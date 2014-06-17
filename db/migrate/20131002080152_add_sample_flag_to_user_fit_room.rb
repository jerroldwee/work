class AddSampleFlagToUserFitRoom < ActiveRecord::Migration
  def change
    add_column :user_fit_rooms, :sample_man, :boolean, :default => false
  end
end
