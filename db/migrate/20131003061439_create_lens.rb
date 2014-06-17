class CreateLens < ActiveRecord::Migration
  def change
    create_table :lens do |t|
      t.string :name
      t.float :price

      t.timestamps
    end

    add_index :lens, :price

    [
      ["No Lens", 0],
      ["Single Vision Clear Lens", 30],
      ["Single Vision Ultra Thin", 55],
      ["Single Vision Photochromic", 58],
      ["Single Vision Polycarbonate", 30],
      ["Progressive Clear Lens", 208],
      ["Progressive Ultra Thin", 258],
      ["Progressive Transition", 358],
      ["Progressive Transition Ultra Thin", 386],
      ["Progressive Polarized", 346],
      ["Progressive Polarized Ultra Thin", 358],
      ["Trivex Clear Lens", 188],
      ["Trivex Transition", 338]
    ].each{|name, price|
      Lens.create(:name => name, :price => price)
    }


    [[]]
  end
end
