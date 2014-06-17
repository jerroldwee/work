class CreateFrameWidths < ActiveRecord::Migration
  def change
    create_table :frame_widths do |t|
      t.string :name

      t.timestamps
    end
    ["Narrow", "Medium", "Wide"].each{|name|FrameWidth.create(:name => name)}
  end
end
