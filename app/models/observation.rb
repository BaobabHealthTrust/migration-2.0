class Observation < ActiveRecord::Base
	set_table_name :obs
	set_primary_key :obs_id
	belongs_to :encounter, :foreign_key => :encounter_id
	belongs_to :patient, :foreign_key => :patient_id
	belongs_to :concept, :foreign_key => :concept_id
	belongs_to :user, :foreign_key => :user_id

end
