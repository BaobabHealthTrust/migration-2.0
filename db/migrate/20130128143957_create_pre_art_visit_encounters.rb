class CreatePreArtVisitEncounters < ActiveRecord::Migration
  def self.up
    create_table :pre_art_visit_encounters do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :pre_art_visit_encounters
  end
end
