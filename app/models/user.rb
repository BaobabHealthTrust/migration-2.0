class User < ActiveRecord::Base
	set_table_name "users"
	belongs_to :person, :foreign_key => :person_id
end
