class VisitEncounter < ActiveRecord::Base
  set_table_name :visit_encounter
  set_primary_key :id

  has_many :encounters, :foreign_key => :encounter_id, :dependent => :destroy
end
