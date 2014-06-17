class CreateFrameShapes < ActiveRecord::Migration
  def change
    create_table :frame_shapes do |t|
      t.string :name

      t.timestamps
    end

    ["Square", "Round", "Rectangle"].each{|name|FrameShape.create(:name => name)}
  end
end
