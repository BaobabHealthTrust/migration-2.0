
def start

	encounter_tables = ["art_visit_encounters","first_visit_encounters", "general_reception_encounters", "hiv_reception_encounters", "give_drugs_encounters", "hiv_staging_encounters", "outcome_encounters", "outpatient_diagnosis_encounters", "pre_art_visit_encounters", "vitals_encounters"]

	encounter_tables.each do |enc_type|
		puts "Encounter type : #{enc_type}"
		patients = Patient.find_by_sql("select patient_id from migrator.#{enc_type} where patient_id not in(select patient_id from migrator.patients)")
	
		patients.each do |patient|
			self.create_patient(Patient.find(patient))
		end
		
	end
	
end


def self.create_patient(pat)
  temp = PatientName.find(:last, :conditions => ["patient_id = ? and voided = 0", pat.id])
  ids = self.get_patient_identifiers(pat.id)
  guardian = Relationship.find(:all, :conditions => ["person_id = ?", pat.id]).last 
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
  patient.void_reason = pat.void_reason
  patient.date_voided = pat.date_voided
  patient.voided_by = pat.voided_by
  patient.date_created = pat.date_created.to_date
  patient.creator = pat.creator

	if pat.voided
	  patient.voided = 1  	
  end
  if !guardian.nil? 
  	patient.guardian_id = guardian.relative_id
  end

  patient.save() rescue nil

end

def self.get_patient_identifiers(pat_id)

	pat_identifiers = Hash.new()	
	
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

start
