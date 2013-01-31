class VisitEncounter < ActiveRecord::Base
	set_table_name "visit_encounters"
	set_primary_key :visit_id
	belongs_to :patient, :foreign_key => :patient_id
end
