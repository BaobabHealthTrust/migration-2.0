class CreateHivStagingEncounters < ActiveRecord::Migration
  def self.up
    create_table :hiv_staging_encounters do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :hiv_staging_encounters
  end
end
