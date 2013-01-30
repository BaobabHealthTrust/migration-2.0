class CreatePatientRecords < ActiveRecord::Migration
  def self.up
    create_table :patient_records do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :patient_records
  end
end
