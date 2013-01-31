class PatientIdentifierType < ActiveRecord::Base
  set_table_name :patient_identifier_type                                   
  has_many :patient_identifiers, :foreign_key => :identifier_type               
  belongs_to :user, :foreign_key => :user_id                                    
  set_primary_key :patient_identifier_type_id

end
