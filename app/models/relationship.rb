class Relationship < ActiveRecord::Base
	set_table_name :relationship
	set_primary_key :relation_id
	belongs_to :relationship_type

end
