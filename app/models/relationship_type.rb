class RelationshipType < ActiveRecord::Base
	has_many :relationships
	set_table_name "relationship_type"
	set_primary_key :relationship_type_id
	
end
