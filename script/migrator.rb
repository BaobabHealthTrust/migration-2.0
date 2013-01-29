	Yes = Concept.find_by_name("Yes")
	No = Concept.find_by_name("No")
	Agrees = Concept.find_by_name("Agrees to followup")
	
	
	
	Hivfirst = EncounterType.find_by_name("HIV first visit")
	Hivrecp = EncounterType.find_by_name("HIV reception")
	Artvisit = EncounterType.find_by_name("ART visit")
	Hiewei = EncounterType.find_by_name("Height/Weight")
	Hivstage = EncounterType.find_by_name("HIV staging")
	Updateoutcome	= EncounterType.find_by_name("Update outcome")			
	Givedrug= EncounterType.find_by_name("Give Drugs")		
	Preart = EncounterType.find_by_name("Pre art visit")
	
def start

	patients = Patient.find(:all, 
	:joins => "inner join encounter as e on e.patient_id = patient.patient_id",
	:group => "e.patient_id" )
	
	count = patients.length
	puts "Number of patients to be migrated #{count}"
	sleep 2 
	
	patients.each do |patient|
		
		 enc_type = ["HIV Reception", "HIV first visit", "Height/Weight", 
		             "HIV staging", "ART visit", "Update outcome", 
		             "Give Drugs", "Pre ART visit"]
		
		 enc_type.each do |enc_type|
		 		encounters = Encounter.find(:all,
		 :conditions => [" patient_id = ? and encounter_type = ?", patient.id, self.get_encounter(enc_type)],
		 :group => "date(encounter_datetime)")

			 encounters.each do |enc|
			 	enc.observations
			 end

		end
	end
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
