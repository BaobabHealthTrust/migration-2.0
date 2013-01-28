class CreateGuardians < ActiveRecord::Migration
  def self.up
    create_table :guardians do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :guardians
  end
end
