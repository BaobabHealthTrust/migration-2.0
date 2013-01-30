class Observation < ActiveRecord::Base
	set_table_name "observations"
	set_primary_key :observation_id
	belongs_to :encounter, :foreign_key => :encounter_id
	belongs_to :patient, :foreign_key => :patient_id
	belongs_to :user, :foreign_key => :user_id

end
