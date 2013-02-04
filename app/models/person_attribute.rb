class PersonAttribute < ActiveRecord::Base
  set_table_name "person_attribute"
  set_primary_key "person_attribute_id"
  belongs_to :patient, :foreign_key => 'person_id'

end
