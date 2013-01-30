class CreateDrugOrders < ActiveRecord::Migration
  def self.up
    create_table :drug_orders do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :drug_orders
  end
end
