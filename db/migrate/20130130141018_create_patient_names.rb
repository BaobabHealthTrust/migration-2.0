class CreatePatientNames < ActiveRecord::Migration
  def self.up
    create_table :patient_names do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :patient_names
  end
end
