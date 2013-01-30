class CreateArtVisitEncounters < ActiveRecord::Migration
  def self.up
    create_table :art_visit_encounters do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :art_visit_encounters
  end
end
