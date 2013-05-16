class PatientAddress < ActiveRecord::Base
  set_table_name 'patient_address'                                        
  belongs_to :patient, :foreign_key => :patient_id                              
  belongs_to :user, :foreign_key => :creator                                    

end
