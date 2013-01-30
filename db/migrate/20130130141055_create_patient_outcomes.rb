class CreatePatientOutcomes < ActiveRecord::Migration
  def self.up
    create_table :patient_outcomes do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :patient_outcomes
  end
end
