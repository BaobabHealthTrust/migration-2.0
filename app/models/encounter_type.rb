class EncounterType < ActiveRecord::Base
	set_table_name "encounter_types"
	set_primary_key :encounter_type_id
	has_many :encounters
end
