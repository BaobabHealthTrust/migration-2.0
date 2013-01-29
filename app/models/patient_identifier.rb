class PatientIdentifier < ActiveRecord::Base
  set_table_name 'patient_identifier'                                        
  belongs_to :type, :class_name => "PatientIdentifierType", :foreign_key => :identifier_type
  belongs_to :patient, :foreign_key => :patient_id                              
  belongs_to :user, :foreign_key => :user_id                                    
  belongs_to :location, :foreign_key => :location_id                            




end
