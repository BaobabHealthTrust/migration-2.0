	Yes = Concept.find_by_name("Yes")
	No = Concept.find_by_name("No")
	Agrees = Concept.find_by_name("Agrees to followup")
	
	
	
	Hivfirst = EncounterType.find_by_name("HIV first visit")
	Hivrecp = EncounterType.find_by_name("HIV reception")
	Artvisit = EncounterType.find_by_name("ART visit")
	Heiwei = EncounterType.find_by_name("Height/Weight")
	Hivstage = EncounterType.find_by_name("HIV staging")
	Updateoutcome	= EncounterType.find_by_name("Update outcome")			
	Givedrug= EncounterType.find_by_name("Give Drugs")		
	Preart = EncounterType.find_by_name("Pre art visit")
	
def start

	patients = Patient.find(:all, 
	:joins => "inner join encounter as e on e.patient_id = patient.patient_id",
  :conditions =>["e.patient_id = 15586"],
	:group => "e.patient_id",:limit => 10)
	
	count = patients.length
	puts "Number of patients to be migrated #{count}"
	sleep 2 
	
	patients.each do |patient|
		 enc_type = ["HIV Reception", "HIV first visit", "Height/Weight", 
		             "HIV staging", "ART visit", "Update outcome", 
		             "Give Drugs", "Pre ART visit"]
	  enc_type = ['HIV first visit']	
		enc_type.each do |enc_type|
		 		encounters = Encounter.find(:all,
		 :conditions => [" patient_id = ? and encounter_type = ?", patient.id, self.get_encounter(enc_type)])

      encounters.each do |enc|
        visit_encounter_id = self.check_for_visitdate(patient.id,enc.encounter_datetime.to_date)
        self.create_record(visit_encounter_id, enc)
      end
		end
	end

end

def self.create_record(visit_encounter_id, encounter)
  case encounter.name.upcase
    when 'HIV FIRST VISIT'
      enc = FirstVisitEncounter.new()
      enc.patient_id = encounter.patient_id
      enc.visit_encounter_id = visit_encounter_id
      enc.date_created = encounter.date_created
      (encounter.observations || []).each do |ob|
        case ob.concept.name.upcase
          when 'AGREES TO FOLLOWUP'
            enc.agrees_to_follow_up = Concept.find(ob.value_coded).name
          when 'EVER RECEIVED ART'
            enc.ever_received_arv = Concept.find(ob.value_coded).name
          when 'EVER REGISTERED AT ART CLINIC'
            enc.ever_registered_at_art = Concept.find(ob.value_coded).name
          when 'LOCATION OF FIRST POSITIVE HIV TEST'
            enc.location_of_hiv_pos_test = Location.find(ob.value_numeric.to_i).name rescue 'Unknown'
          when 'DATE OF POSITIVE HIV TEST'
            enc.date_of_hiv_pos_test = ob.value_datetime
          when 'ARV NUMBER AT THAT SITE'
            enc.arv_number_at_that_site = ob.value_numeric
          when 'LOCATION OF ART INITIATION'
            enc.location_of_art_initiation = Location.find(ob.value_numeric.to_i).name rescue 'Unknown'
          when 'TAKEN ARVS IN LAST 2 MONTHS'
            enc.taken_arvs_in_last_two_months = Concept.find(ob.value_coded).name
          when 'LAST ARV DRUGS TAKEN'
            enc.last_arv_regimen = Concept.find(ob.value_coded).name
          when 'TAKEN ART IN LAST 2 WEEKS'
            enc.taken_arvs_in_last_two_weeks = Concept.find(ob.value_coded).name
          when 'HAS TRANSFER LETTER'
            enc.has_transfer_letter = Concept.find(ob.value_coded).name
          when 'SITE TRANSFERRED FROM'
            enc.site_transferred_from = Location.find(ob.value_numeric.to_i).name rescue 'Unknown'
          when 'DATE OF ART INITIATION'
            enc.date_of_art_initiation = ob.value_datetime
          when 'DATE LAST ARVS TAKEN'
            enc.date_last_arv_taken = ob.value_datetime
        end
        enc.save
      end
  end
end


def self.check_for_visitdate(patient_id,encounter_date)                                                 
  vdate = VisitEncounter.find(:first,                                    
    :conditions => ["patient_id = ? AND visit_date = ?",                      
    patient_id,encounter_date])                               
  if vdate.blank?                                                        
    vdate = VisitEncounter.new()                                              
    vdate.visit_date = encounter_date.to_date                              
    vdate.patient_id = patient_id                                        
    vdate.save                                                                
  end                  
  return vdate.id                                                        
end 

def self.get_encounter(type)
 case type
 	when 'ART visit'
 	 return Artvisit.id
 	when 'HIV Reception'
 		return 	Hivrecp.id
 	when 'HIV first visit'
 		return Hivfirst.id
 	when 'Height/Weight' 
 		return Heiwei.id
	when 'HIV staging' 
		return Hivstage.id
	when 'Update outcome'
		return Updateoutcome.id 
	when 'Give Drugs'
		return Givedrug.id
 	when 'Pre ART visit'
 		return Preart.id
 end
end


start 
