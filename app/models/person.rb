class Person < ActiveRecord::Base
	set_table_name :person
	set_primary_key :person_id
	has_one :patient
	belongs_to :user,:foreign_key => :user_id
	
end
