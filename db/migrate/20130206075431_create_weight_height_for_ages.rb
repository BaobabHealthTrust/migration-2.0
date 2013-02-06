class CreateWeightHeightForAges < ActiveRecord::Migration
  def self.up
    create_table :weight_height_for_ages do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :weight_height_for_ages
  end
end
