class CreateFirstVisitEncounters < ActiveRecord::Migration
  def self.up
    create_table :first_visit_encounters do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :first_visit_encounters
  end
end
