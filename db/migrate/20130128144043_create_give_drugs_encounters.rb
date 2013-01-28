class CreateGiveDrugsEncounters < ActiveRecord::Migration
  def self.up
    create_table :give_drugs_encounters do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :give_drugs_encounters
  end
end
