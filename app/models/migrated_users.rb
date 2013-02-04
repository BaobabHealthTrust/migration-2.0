class MigratedUsers < ActiveRecord::Base
	set_table_name "users"
	set_primary_key :user_id
end
