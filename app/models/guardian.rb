class Guardian < ActiveRecord::Base

	set_table_name "guardians"
	set_primary_key :guardian_id
	has_many :observations, :foreign_key => :encounter_id
	belongs_to :user, :foreign_key => :creator_id
	has_many :patients, :class_name => "PatientRecord", :foreign_key => :guardian_id
end
