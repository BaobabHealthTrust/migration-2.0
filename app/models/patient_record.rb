class PatientRecord < ActiveRecord::Base
  set_table_name :patients                                             
  set_primary_key :id

  has_many :first_visit_encounters, :foreign_key => :patient_id,        
    :dependent => :destroy, :class => 'FirstVisitEncounter'                     
  has_many :give_drugs_encounters, :foreign_key => :patient_id,         
    :dependent => :destroy, :class => 'GiveDrugsEncounter'                      
  has_many :hiv_staging_encounters, :foreign_key => :patient_id,        
    :dependent => :destroy, :class => 'HivStagingEncounter'                     
  has_many :outcome_encounters, :foreign_key => :patient_id,            
    :dependent => :destroy, :class => 'OutcomeEncounter'                        
  has_many :pre_art_encounters, :foreign_key => :patient_id,            
    :dependent => :destroy, :class => 'PreArtVisitEncounter'                    
  has_many :art_encounters, :foreign_key => :patient_id,                
    :dependent => :destroy, :class => 'ArtVisitEncounter'                       
  has_many :vitals_encounters, :foreign_key => :patient_id,             
    :dependent => :destroy, :class => 'VitalsEncounter' 
end
