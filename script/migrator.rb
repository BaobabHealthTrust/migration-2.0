	require 'thread'
		
	Hivfirst = EncounterType.find_by_name("HIV first visit")
	Hivrecp = EncounterType.find_by_name("HIV Reception")
	Artvisit = EncounterType.find_by_name("ART visit")
	Heiwei = EncounterType.find_by_name("Height/Weight")
	Hivstage = EncounterType.find_by_name("HIV staging")
	Updateoutcome	= EncounterType.find_by_name("Update outcome")			
	Givedrug= EncounterType.find_by_name("Give Drugs")		
	Preart = EncounterType.find_by_name("Pre ART visit")
	Concepts = Hash.new()
	
	
	
	
def start
  t1 = Time.now
	Concept.find(:all).map do |con|
			Concepts[con.id] = con
	end
	t2 = Time.now
	elapsed = time_diff_milli t1, t2
	puts "Loaded concepts in #{elapsed}"
	
	patients = Patient.find(:all, :limit => 10)
	count = patients.length
	puts "Number of patients to be migrated #{count}"
	sleep 2 
	total_enc = 0
	t1 = Time.now
	patients.each do |patient|
		 enc_type = ["HIV Reception", "HIV first visit", "Height/Weight", 
		             "HIV staging", "ART visit", "Update outcome", 
		             "Give drugs", "Pre ART visit"]	             
				enc_type.each do |enc_type|

		 		encounters = Encounter.find(:all,
				 :conditions => [" patient_id = ? and encounter_type = ?", patient.id, self.get_encounter(enc_type)])
					encounters.each do |enc|
					total_enc +=1
		      visit_encounter_id = self.check_for_visitdate(patient.id,enc.encounter_datetime.to_date)
		      self.create_record(visit_encounter_id, enc)
	      end
    	end
		self.create_patient(patient)
		self.create_guardian(patient)
    puts "#{count-=1}................ Patient(s) to go"
    pt2 = Time.now
    elapsed = time_diff_milli t1, pt2
  	eps = total_enc / elapsed
  	puts "#{total_enc} Encounters were processed in #{elapsed} for #{eps} eps"
	end
	t2 = Time.now
	elapsed = time_diff_milli t1, t2
	eps = total_enc / elapsed
	puts "Loaded concepts in #{elapsed}"
	puts "#{total_enc} Encounters were processed in #{elapsed} for #{eps} eps"
end

def time_diff_milli(start, finish)
   (finish - start) * 1000.0
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
	when 'Give drugs'
		return Givedrug.id
 	when 'Pre ART visit'
 		return Preart.id
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

def self.create_patient(pat)
	temp = PatientName.find(:last, :conditions => ["patient_id = ? and voided = 0", pat.id])
	ids = self.get_patient_identifiers(pat.id)
	patient = PatientRecord.new()
	patient.patient_id = pat.id
	patient.given_name = temp.given_name rescue nil 
	patient.middle_name = temp.middle_name rescue nil
	patient.family_name = temp.family_name rescue nil
	patient.gender = pat.gender
	patient.dob = pat.birthdate
	patient.dob_estimated = pat.birthdate_estimated
	patient.traditional_authority = ids["ta"]
#	current_address = ids["ta"]
#	landmark= 
	patient.cellphone_number= ids["cell"]
	patient.home_phone_number= ids["home_phone"]
	patient.office_phone_number= ids["office_phone"]
	patient.occupation= ids["occ"]
	patient.dead = pat.dead
	patient.nat_id = ids["nat_id"]
	patient.art_number= ids["art_number"]
	patient.pre_art_number= ids["pre_arv_number"]
	patient.tb_number= ids["tb_id"]
	#legacy_id
	#legacy_id2
	#legacy_id3
	patient.new_nat_id= ids["new_nat_id"]
	patient.prev_art_number= ids["pre_arv_number"]
	patient.filing_number= ids["filing_number"]
	patient.archived_filing_number= ids["archived_filing_number"]
	patient.voided = pat.voided
	patient.void_reason = pat.void_reason
	patient.date_voided = pat.date_voided
	patient.voided_by = pat.voided_by
	patient.date_created = pat.date_created.to_date
	patient.creator = pat.creator

	patient.save()
end

def self.create_guardian(pat)
		relatives = Relationship.find(:all, :conditions => ["person_id = ?", pat.id])
		relatives.each do |relative|
			guardian = Guardian.new()
			temp_relative = Patient.find(:last, :conditions => ["patient_id = ? ", relative.relative_id])
			temp = PatientName.find(:last, :conditions => ["patient_id = ? and voided = 0", relative.relative_id])
			guardian.patient_id = pat.id
			guardian.family_name = temp.family_name  rescue nil
			guardian.name = temp.given_name rescue nil
			guardian.gender = temp_relative.gender rescue nil
			guardian.relationship = RelationshipType.find(ralative.relationship).name
			guardian.creator = temp_relative.creator
			guardian.save
		end
end

def self.get_patient_identifiers(pat_id)
	pat_identifiers = Hash.new('NULL')	
	
	identifiers = PatientIdentifier.find(:all, :conditions => ["patient_id = ? and voided = 0", pat_id])
	identifiers.each do |id|
		id_type=PatientIdentifierType.find(id.identifier_type).name
		case id_type.upcase
			when 'NATIONAL ID' 
				pat_identifiers["nat_id"] = id.identifier
			when 'OCCUPATION'
				pat_identifiers["occ"] = id.identifier				
			when 'CELL PHONE NUMBER'
				pat_identifiers["cell"] = id.identifier			
			when 'TRADITIONAL AUTHORITY '
				pat_identifiers["ta"] = id.identifier
			when 'FILING NUMBER'
				pat_identifiers["filing_number"] = id.identifier
			when 'HOME PHONE NUMBER'
				pat_identifiers["home_phone"] = id.identifier
			when 'OFFICE PHONE NUMBER'
				pat_identifiers["office_phone"] = id.identifier
			when 'ART NUMBER'
				pat_identifiers["art_number"] = id.identifier
			when 'PREVIOUS ART NUMBER'
				pat_identifiers["prev_art_number"] = id.identifier
			when 'NEW NATIONAL ID'
				pat_identifiers["new_nat_id"] = id.identifier
			when 'PRE ARV NUMBER ID'
				pat_identifiers["pre_arv_number"] = id.identifier
			when 'TB TREATMENT ID'
				pat_identifiers["tb_id"] = id.identifier
			when 'ARCHIVED FILING NUMBER'
				pat_identifiers["archived_filing_number"] = id.identifier
		end
	end
	return pat_identifiers
end

def self.create_record(visit_encounter_id, encounter)

  case encounter.name.upcase
  	
  	when 'HIV FIRST VISIT'
  		self.create_hiv_first_visit(visit_encounter_id, encounter)
  	when 'UPDATE OUTCOME'  
	  	self.create_update_outcome(visit_encounter_id, encounter)
    when 'GIVE DRUGS'  
    	self.create_give_drug_record(visit_encounter_id, encounter)
		when 'HEIGHT/WEIGHT'
    	self.create_vitals_record(visit_encounter_id, encounter)
		when 'HIV RECEPTION'
			self.create_hiv_reception_record(visit_encounter_id, encounter)
		when 'PRE ART VISIT'
			self.create_pre_art_record(visit_encounter_id, encounter)
		when 'ART VISIT'
			self.create_art_encounter(visit_encounter_id, encounter)		
		when 'HIV STAGING'
			self.create_hiv_staging_encounter(visit_encounter_id, encounter)		
  end
  
end

def self.create_hiv_first_visit(visit_encounter_id, encounter)

	enc = FirstVisitEncounter.new()
  enc.patient_id = encounter.patient_id
  enc.visit_encounter_id = visit_encounter_id
  enc.date_created = encounter.date_created
  enc.creator = encounter.creator
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

def self.create_give_drug_record(visit_encounter_id, encounter)

  enc = GiveDrugsEncounter.new()
  enc.patient_id = encounter.patient_id
  enc.visit_encounter_id = visit_encounter_id
  enc.date_created = encounter.date_created
  enc.creator = encounter.creator
  give_drugs_count = 1
  (encounter.orders || []).each do |order|  
    (order.drug_orders || []).each do |drug_order|
       self.assign_drugs_dispensed(enc,drug_order,give_drugs_count)
        give_drugs_count+=1
     end
  end
  enc.save

end

def self.assign_drugs_dispensed(encounter,drug_order,count)
  case count
    when 1
      encounter.dispensed_quantity1 = drug_order.quantity
      encounter.drug_name1 = drug_order.drug.name
    when 2
      encounter.dispensed_quantity2 = drug_order.quantity
      encounter.drug_name2 = drug_order.drug.name
    when 3
      encounter.dispensed_quantity3 = drug_order.quantity
      encounter.drug_name3 = drug_order.drug.name
    when 4
      encounter.dispensed_quantity4 = drug_order.quantity
      encounter.drug_name4 = drug_order.drug.name
    when 5
      encounter.dispensed_quantity5 = drug_order.quantity
      encounter.drug_name5 = drug_order.drug.name
  end
end

def self.create_update_outcome(visit_encounter_id, encounter)
      
      enc = OutcomeEncounter.new()
	    enc.patient_id = encounter.patient_id
	    enc.visit_encounter_id = visit_encounter_id
	    enc.date_created = encounter.date_created
	    enc.creator = encounter.creator
	    (encounter.observations || []).each do |ob|
			  case ob.concept.name.upcase
			  when 'OUTCOME'
					enc.state = Concept.find(ob.value_coded).name
					enc.outcome_date = ob.obs_datetime
					if enc.state =='Transfer Out(With Transfer Note)'
						#enc.transferred_out_location
					end
				 end 
		  end
		  
		  enc.save

end

def self.create_vitals_record(visit_encounter_id, encounter)
  
  enc = VitalsEncounter.new()
  enc.patient_id = encounter.patient_id
  enc.visit_encounter_id = visit_encounter_id
  enc.date_created = encounter.date_created
  enc.creator = encounter.creator
  (encounter.observations || []).each do |ob|
    case ob.concept.name.upcase
 		   when 'HEIGHT'
 		     enc.height = ob.value_numeric
		   when 'WEIGHT' 
		     enc.weight = ob.value_numeric
    end
  end

  current_height = Observation.find(:last,
  :conditions => ["concept_id = ? and patient_id = ?",Height.id,encounter.patient_id]).value_numeric.to_i rescue nil
  enc.bmi = (enc.weight/(current_height*current_height)*10000) rescue nil
  enc.save 
end

def	self.create_hiv_reception_record(visit_encounter_id, encounter)
	enc = HivReceptionEncounter.new()
	enc.patient_id = encounter.patient_id
	enc.visit_encounter_id = visit_encounter_id
	enc.date_created = encounter.date_created
	enc.creator = encounter.creator
	(encounter.observations || []).each do |ob|
		case ob.concept.name.upcase
 		   when 'GUARDIAN PRESENT'
 		     enc.guardian_present = Concept.find(ob.value_coded).name
		   when 'PATIENT PRESENT' 
		     enc.patient_present = Concept.find(ob.value_coded).name
    end
		
	end
  enc.save
end

def self.create_pre_art_record(visit_encounter_id, encounter)
	enc = PreArtVisitEncounter.new()
	enc.patient_id = encounter.patient_id
	enc.visit_encounter_id = visit_encounter_id
	enc.date_created = encounter.date_created
	enc.creator = encounter.creator
	(encounter.observations || []).each do |ob|
  	self.repeated_obs(enc, ob)
	end
	drug_induced_symptom (enc) rescue nil
  enc.save
end

def self.assign_drugs_prescribed(enc,prescribed_drug_name_hash,prescribed_drug_dosage_hash,prescribed_drug_frequency_hash) 
  count = 1
  (prescribed_drug_name_hash).each do | drug_name, name |
    case count
      when 1
        enc.drug1 = drug_name
        enc.dosage1 = prescribed_drug_dosage_hash[drug_name]
        enc.frequency1 = prescribed_drug_frequency_hash[drug_name]
        count+=1
      when 2
        enc.drug2 = drug_name
        enc.dosage2 = prescribed_drug_dosage_hash[drug_name]
        enc.frequency2 = prescribed_drug_frequency_hash[drug_name]
        count+=1
      when 3
        enc.drug3 = drug_name
        enc.dosage3 = prescribed_drug_dosage_hash[drug_name]
        enc.frequency3 = prescribed_drug_frequency_hash[drug_name]
        count+=1
      when 4
        enc.drug4 = drug_name
        enc.dosage4 = prescribed_drug_dosage_hash[drug_name]
        enc.frequency4 = prescribed_drug_frequency_hash[drug_name]
        count+=1
    end
  end
end

def self.assign_drugs_counted(encounter,obs,count)
  case count
    when 1
      encounter.drug_name_brought_to_clinic1 = Drug.find(obs.value_drug).name 
      encounter.drug_quantity_brought_to_clinic1 = obs.value_numeric
    when 2
      encounter.drug_name_brought_to_clinic2 = Drug.find(obs.value_drug).name 
      encounter.drug_quantity_brought_to_clinic2 = obs.value_numeric
    when 3
      encounter.drug_name_brought_to_clinic3 = Drug.find(obs.value_drug).name 
      encounter.drug_quantity_brought_to_clinic3 = obs.value_numeric
    when 4
      encounter.drug_name_brought_to_clinic4 = Drug.find(obs.value_drug).name 
      encounter.drug_quantity_brought_to_clinic4 = obs.value_numeric
  end
end

def self.assign_drugs_counted_but_not_brought(encounter,obs,count)
  case count
    when 1
      encounter.drug_left_at_home1 = obs.value_numeric
    when 2
      encounter.drug_left_at_home2 = obs.value_numeric
    when 3
      encounter.drug_left_at_home3 = obs.value_numeric
    when 4
      encounter.drug_left_at_home4 = obs.value_numeric
  end
end

def	self.create_art_encounter(visit_encounter_id, encounter)		
  enc = ArtVisitEncounter.new()
	enc.patient_id = encounter.patient_id
	enc.visit_encounter_id = visit_encounter_id
	enc.date_created = encounter.date_created
	enc.creator = encounter.creator

  drug_name_brought_to_clinic_count = 1
  drug_name_not_brought_to_clinic_count = 1
  prescribed_drug_name_hash = {}
  prescribed_drug_dosage_hash = {}
  prescribed_drug_frequency_hash = {}

	(encounter.observations || []).each do |ob|
		case ob.concept.name.upcase
      when 'WHOLE TABLETS REMAINING AND BROUGHT TO CLINIC'	
        self.assign_drugs_counted(enc,ob,drug_name_brought_to_clinic_count)
        drug_name_brought_to_clinic_count+=1
      when 'WHOLE TABLETS REMAINING BUT NOT BROUGHT TO CLINIC'
        self.assign_drugs_counted_but_not_brought(enc,ob,drug_name_not_brought_to_clinic_count)
        drug_name_not_brought_to_clinic_count+=1
      when 'PRESCRIPTION TIME PERIOD'	
        enc.prescription_duration = ob.value_text
      when 'PRESCRIBE RECOMMENDED DOSAGE'
      when 'PRESCRIBED DOSE'
        drug_name = Drug.find(ob.value_drug).name
        if prescribed_drug_name_hash[drug_name].blank?
          prescribed_drug_name_hash[drug_name] = drug_name
          prescribed_drug_dosage_hash[drug_name] = "#{ob.value_numeric}"
          prescribed_drug_frequency_hash[drug_name] = ob.value_text
        else
          prescribed_drug_dosage_hash[drug_name] += "-#{ob.value_numeric}"
          prescribed_drug_frequency_hash[drug_name] += "-#{ob.value_text}"
        end
      else
    		self.repeated_obs(enc, ob)    	
    end
  unless prescribed_drug_name_hash.blank?
    self.assign_drugs_prescribed(enc,prescribed_drug_name_hash,prescribed_drug_dosage_hash,prescribed_drug_frequency_hash) 
  end
	end
	self.drug_induced_symptom(enc) rescue nil
	enc.save
end

def	self.create_hiv_staging_encounter(visit_encounter_id, encounter)		
	startreason = PersonAttributeType.find_by_name("reason antiretrovirals started").person_attribute_type_id
	whostage =  PersonAttributeType.find_by_name("WHO stage").person_attribute_type_id
	enc = HivStagingEncounter.new()
  enc.patient_id = encounter.patient_id
  enc.visit_encounter_id = visit_encounter_id
  enc.date_created = encounter.date_created
  enc.creator = encounter.creator
  enc.who_stage = PersonAttribute.find(:last, :conditions => ["person_id = ? and person_attribute_type_id = ?",encounter.patient_id, whostage]).value 
  enc.reason_for_starting_art = PersonAttribute.find(:last, :conditions => ["person_id = ? and person_attribute_type_id = ?",encounter.patient_id, startreason]).value 
  (encounter.observations || []).each do |ob|
  		self.repeated_obs(enc, ob)
	end
  enc.save
end

def self.repeated_obs(enc, ob)

	case ob.concept.name.upcase
    when 'PREGNANT'
     	enc.patient_pregnant = self.get_concept(ob.value_coded)
		when 'BREASTFEEDING'
  		enc.patient_breast_feeding = self.get_concept(ob.value_coded)
		when 'CURRENTLY USING FAMILY PLANNING METHOD'
			enc.using_family_planning_method = self.get_concept(ob.value_coded)
		when 'FAMILY PLANNING METHOD'
			enc.family_planning_method_used = self.get_concept(ob.value_coded)
		when 'ABDOMINAL PAIN'
			enc.abdominal_pains = self.get_concept(ob.value_coded)
		when 'ANOREXIA'	
			enc.anorexia = self.get_concept(ob.value_coded)
		when 'COUGH'	
			enc.cough = self.get_concept(ob.value_coded)
		when 'DIARRHOEA'	
			enc.diarrhoea = self.get_concept(ob.value_coded)
		when 'FEVER'	
			enc.fever = self.get_concept(ob.value_coded)
		when 'JAUNDICE'	
			enc.jaundice = self.get_concept(ob.value_coded)
		when 'LEG PAIN / NUMBNESS'
			enc.leg_pain_numbness = self.get_concept(ob.value_coded)
		when 'VOMIT'
			enc.vomit = self.get_concept(ob.value_coded)
		when 'WEIGHT LOSS'
			enc.weight_loss  = self.get_concept(ob.value_coded)
		when 'PERIPHERAL NEUROPATHY'
			enc.peripheral_neuropathy = self.get_concept(ob.value_coded)
		when 'HEPATITIS'
			enc.hepatitis = self.get_concept(ob.value_coded)
		when 'ANAEMIA'
			enc.anaemia = self.get_concept(ob.value_coded)
		when 'LACTIC ACIDOSIS'
			enc.lactic_acidosis = self.get_concept(ob.value_coded)
		when 'LIPODYSTROPHY'
			enc.lipodystrophy = self.get_concept(ob.value_coded)
		when 'SKIN RASH'
			enc.skin_rash = self.get_concept(ob.value_coded)
		when 'TB STATUS'
			enc.tb_status = self.get_concept(ob.value_coded)
		when 'REFER PATIENT TO CLINICIAN'
			enc.refer_to_clinician = self.get_concept(ob.value_coded)
		when 'PRESCRIBE ARVS THIS VISIT'
			enc.prescribe_arv = self.get_concept(ob.value_coded)
		when 'PRESCRIPTION TIME PERIOD'
			enc.prescription_duration = self.get_concept(ob.value_coded)
		when 'ARV REGIMEN'
			enc.arv_regimen = self.get_concept(ob.value_coded)
		when 'PRESCRIBE COTRIMOXAZOLE (CPT)'
			enc.prescribe_cpt  = self.get_concept(ob.value_coded)
		when 'PRESCRIBED ISONIAZED (IPT)'
			enc.prescribe_ipt = self.get_concept(ob.value_coded)
		when 'NUMBER OF CONDOMS GIVEN'
			enc.number_of_condoms_given = ob.value_numeric
		when 'PRESCRIBED DEPO PROVERA'
			enc.depo_provera_given = self.get_concept(ob.value_coded)
		when 'CONTINUE TREATMENT AT CURRENT CLINIC'
			enc.continue_treatment_at_clinic = self.get_concept(ob.value_coded)
		when 'CD4 COUNT AVAILABLE'
      enc.cd4_count_available = self.get_concept(ob.value_coded)
    when 'CD4 COUNT'
      enc.cd4_count = ob.value_numeric
      enc.cd4_count_modifier = ob.value_modifier
    when 'CD4 TEST DATE'
      enc.date_of_cd4_count = ob.value_datetime
		when 'ASYMPTOMATIC'
      enc.asymptomatic = self.get_concept(ob.value_coded)
    when 'PERSISTENT GENERALISED LYMPHADENOPATHY'
     	enc.persistent_generalized_lymphadenopathy = self.get_concept(ob.value_coded)
		when 'UNSPECIFIED STAGE 1 CONDITION'
      enc.unspecified_stage_1_cond= self.get_concept(ob.value_coded)                
    when 'MOLLUSCUMM CONTAGIOSUM'
      enc.molluscumm_contagiosum = self.get_concept(ob.value_coded)
    when 'WART VIRUS INFECTION, EXTENSIVE' 
      enc.wart_virus_infection_extensive = self.get_concept(ob.value_coded)
    when 'ORAL ULCERATIONS, RECURRENT'
      enc.oral_ulcerations_recurrent = self.get_concept(ob.value_coded)
    when  'PAROTID ENLARGEMENT, PERSISTENT UNEXPLAINED'
      enc.parotid_enlargement_persistent_unexplained = self.get_concept(ob.value_coded)
    when 'LINEAL GINGIVAL ERYTHEMA'
      enc.lineal_gingival_erythema = self.get_concept(ob.value_coded)
    when 'HERPES ZOSTER'
      enc.herpes_zoster = self.get_concept(ob.value_coded)
	  when 'RESPIRATORY TRACT INFECTIONS, RECURRENT(SINUSITIS, TONSILLITIS, OTITIS MEDIA, PHARYNGITIS)'
      enc.respiratory_tract_infections_recurrent = self.get_concept(ob.value_coded)
    when 'UNSPECIFIED STAGE 2 CONDITION'
      enc.unspecified_stage2_condition =self.get_concept(ob.value_coded)
    when 'ANGULAR CHEILITIS'
      enc.angular_chelitis = self.get_concept(ob.value_coded)
    when 'PAPULAR PRURITIC ERUPTIONS / FUNGAL NAIL INFECTIONS'
      enc.papular_prurtic_eruptions = self.get_concept(ob.value_coded)
    when 'HEPATOSPLENOMEGALY, PERSISTENT UNEXPLAINED'
      enc.hepatosplenomegaly_unexplained = self.get_concept(ob.value_coded)
    when'ORAL HAIRY LEUKOPLAKIA'
      enc.oral_hairy_leukoplakia =self.get_concept(ob.value_coded)
    when'SEVERE WEIGHT LOSS >10% AND/OR BMI <18.5KG/M(SQUARED), UNEXPLAINED'
      enc.severe_weight_loss = self.get_concept(ob.value_coded)
    when'FEVER, PERSISTENT UNEXPLAINED (INTERMITTENT OR CONSTANT, > 1 MONTH)'
      enc.fever_persistent_unexplained = self.get_concept(ob.value_coded)
    when'PULMONARY TUBERCULOSIS (CURRENT)'
      enc.pulmonary_tuberculosis = self.get_concept(ob.value_coded)
    when'PULMONARY TUBERCULOSIS WITHIN THE last 2 YEARS'
     	enc.pulmonary_tuberculosis_last_2_years = self.get_concept(ob.value_coded)
    when'SEVERE BACTERIAL INFECTIONS (PNEUMONIA, EMPYEMA, PYOMYOSITIS, BONE/JOINT, MENINGITIS, BACTERAEMIA)'							
     	enc.severe_bacterial_infection = self.get_concept(ob.value_coded)
    when'BACTERIAL PNEUMONIA, RECURRENT SEVERE'							
     	enc.bacterial_pnuemonia = self.get_concept(ob.value_coded)
    when'SYMPTOMATIC LYMPHOID INTERSTITIAL PNEUMONITIS'
      enc.symptomatic_lymphoid_interstitial_pnuemonitis = self.get_concept(ob.value_coded)
    when'CHRONIC HIV-ASSOCIATED LUNG DISEASE INCLUDING BRONCHIECTASIS'
      enc.chronic_hiv_assoc_lung_disease = self.get_concept(ob.value_coded)
    when'UNSPECIFIED STAGE 3 CONDITION'
      enc.unspecified_stage3_condition = self.get_concept(ob.value_coded)
    when'ANAEMIA'
      enc.aneamia = self.get_concept(ob.value_coded)
    when'NEUTROPAENIA, UNEXPLAINED < 500 /MM(CUBED)'
      enc.neutropaenia = self.get_concept(ob.value_coded)
    when'THROMBOCYTOPAENIA, CHRONIC < 50,000 /MM(CUBED)'
      enc.thrombocytopaenia_chronic = self.get_concept(ob.value_coded)
    when'DIARRHOEA'
      enc.diarhoea = self.get_concept(ob.value_coded)
    when'ORAL CANDIDIASIS'
      enc.oral_candidiasis = self.get_concept(ob.value_coded)
    when'ACUTE NECROTIZING ULCERATIVE GINGIVITIS OR PERIODONTITIS'
      enc.acute_necrotizing_ulcerative_gingivitis = self.get_concept(ob.value_coded)
    when'LYMPH NODE TUBERCLOSIS'
     	enc.lymph_node_tuberculosis = self.get_concept(ob.value_coded)
    when'TOXOPLASMOSIS OF THE BRAIN'
      enc.toxoplasmosis_of_brain = self.get_concept(ob.value_coded)
    when'CRYPTOCOCCAL MENINGITIS'
			enc.cryptococcal_meningitis = self.get_concept(ob.value_coded)
    when'PROGRESSIVE MULTIFOCAL LEUKOENCEPHALOPATHY'
      enc.progressive_multifocal_leukoencephalopathy = self.get_concept(ob.value_coded)
    when'DISSEMINATED MYCOSIS (COCCIDIOMYCOSIS OR HISTOPLASMOSIS)'
      enc.disseminated_mycosis = self.get_concept(ob.value_coded)
    when'CANDIDIASIS OF OESOPHAGUS'
      enc.candidiasis_of_oesophagus = self.get_concept(ob.value_coded)
    when'EXTRAPULMONARY TUBERCULOSIS'
       enc.extrapulmonary_tuberculosis = self.get_concept(ob.value_coded)
    when'CEREBRAL OR B-CELL NON-HODGKIN LYMPHOMA'
       enc.cerebral_non_hodgkin_lymphoma = self.get_concept(ob.value_coded)
    when"KAPOSI'S SARCOMA"
      enc.kaposis = self.get_concept(ob.value_coded)
    when'HIV ENCEPHALOPATHY'
      enc.hiv_encephalopathy = self.get_concept(ob.value_coded)
    when'UNSPECIFIED STAGE 4 CONDITION'
      enc.unspecified_stage_4_condition = self.get_concept(ob.value_coded)
    when'PNEUMOCYSTIS PNEUMONIA'
      enc.pnuemocystis_pnuemonia = self.get_concept(ob.value_coded)
    when'DISSEMINATED NON-TUBERCLOSIS MYCOBACTERIAL INFECTION'
      enc.disseminated_non_tuberculosis_mycobactierial_infection = self.get_concept(ob.value_coded)
    when'CRYPTOSPORIDIOSIS OR ISOSPORIASIS'
      enc.cryptosporidiosis = self.get_concept(ob.value_coded)
    when'ISOSPORIASIS >1 MONTH'
      enc.isosporiasis = self.get_concept(ob.value_coded)
    when'SYMPTOMATIC HIV-ASSOCIATED NEPHROPATHY OR CARDIOMYOPATHY'
      enc.symptomatic_hiv_asscoiated_nephropathy = self.get_concept(ob.value_coded)
    when'CHRONIC HERPES SIMPLEX INFECTION(OROLABIAL, GENITAL / ANORECTAL >1 MONTH OR VISCERAL AT ANY SITE)'
      enc.chronic_herpes_simplex_infection = self.get_concept(ob.value_coded)
    when'CYTOMEGALOVIRUS INFECTION (RETINITIS OR INFECTION OF OTHER ORGANS)'
      enc.cytomegalovirus_infection = self.get_concept(ob.value_coded)
    when'TOXOPLASMOSIS OF THE BRAIN (FROM AGE 1 MONTH)'
      enc.toxoplasomis_of_the_brain_1month = self.get_concept(ob.value_coded)
    when'RECTO-VAGINAL FISTULA, HIV-ASSOCIATED'
      enc.recto_vaginal_fitsula = self.get_concept(ob.value_coded)
    when'REASON ANTIRETROVIRALS STARTED'
      enc.reason_for_starting_art = self.get_concept(ob.value_coded)
    when'WHO STAGE'
      enc.who_stage = self.get_concept(ob.value_coded)
      
	end
end

def self.drug_induced_symptom (enc) 
			if enc.lipodystrophy.upcase == 'YES DRUG INDUCED' 
				enc.drug_induced_lipodystrophy = 'Yes'
			end
			if enc.abdominal_pains.upcase == 'YES DRUG INDUCED' 
					enc.drug_induced_abdominal_pains = 'Yes'
			end
			if enc.skin_rash.upcase == 'YES DRUG INDUCED' 
				enc.drug_induced_skin_rash = 'Yes'
			end
			if enc.anorexia.upcase == 'YES DRUG INDUCED' 
					enc.drug_induced_anorexia = 'Yes'
			end
			if enc.diarrhoea.upcase == 'YES DRUG INDUCED' 
					enc.drug_induced_diarrhoea = 'Yes'
			end			
			if enc.jaundice.upcase == 'YES DRUG INDUCED' 
					enc.drug_induced_jaundice = 'Yes'
			end			
			if enc.leg_pain_numbness.upcase == 'YES DRUG INDUCED' 
				enc.drug_induced_leg_pain_numbness = 'Yes'
			end
			if enc.vomit.upcase == 'YES DRUG INDUCED' 
				enc.drug_induced_vomit = 'Yes'
			end
			if enc.peripheral_neuropathy.upcase == 'YES DRUG INDUCED' 
				enc.drug_induced_peripheral_neuropathy = 'Yes'
			end			
			if enc.hepatitis.upcase == 'YES DRUG INDUCED' 
				enc.drug_induced_hepatitis = 'Yes'
			end
			if enc.anaemia.upcase == 'YES DRUG INDUCED' 
				enc.drug_induced_anaemia = 'Yes'
			end
			if enc.lactic_acidosis.upcase == 'YES DRUG INDUCED' 
				enc.drug_induced_lactic_acidosis = 'Yes'
			end			

end

def self.get_concept(id)
	if Concepts[id] == nil
		return Concept.find(id).name
	else
		return Concepts[id].name
	end
end
start 
