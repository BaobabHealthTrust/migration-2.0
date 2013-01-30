class CreateVitalsEncounters < ActiveRecord::Migration
  def self.up
    create_table :vitals_encounters do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :vitals_encounters
  end
end
