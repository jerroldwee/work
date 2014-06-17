class CreateMaterials < ActiveRecord::Migration
  def change
    create_table :materials do |t|
      t.string :name

      t.timestamps
    end
    ["Acetate", "Titanium", "Rimless"].each{|name|Material.create(:name => name)}
  end
end
