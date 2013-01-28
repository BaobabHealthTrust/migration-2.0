class CreateOutcomeEncounters < ActiveRecord::Migration
  def self.up
    create_table :outcome_encounters do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :outcome_encounters
  end
end
