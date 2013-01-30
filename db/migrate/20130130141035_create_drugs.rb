class CreateDrugs < ActiveRecord::Migration
  def self.up
    create_table :drugs do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :drugs
  end
end
