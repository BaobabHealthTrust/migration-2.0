class CreateHivReceptionEncounters < ActiveRecord::Migration
  def self.up
    create_table :hiv_reception_encounters do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :hiv_reception_encounters
  end
end
