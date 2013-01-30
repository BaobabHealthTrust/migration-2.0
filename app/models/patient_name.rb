class PatientName < ActiveRecord::Base
  set_table_name :patient_name                                             
  belongs_to :patient, :foreign_key => :patient_id                              
  belongs_to :user, :foreign_key => :user_id                                    
  set_primary_key :patient_name_id



end
