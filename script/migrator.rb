require 'thread'

Hivfirst = EncounterType.find_by_name("HIV first visit")
Hivrecp = EncounterType.find_by_name("HIV Reception")
Artvisit = EncounterType.find_by_name("ART visit")
Heiwei = EncounterType.find_by_name("Height/Weight")
Hivstage = EncounterType.find_by_name("HIV staging")
Updateoutcome = EncounterType.find_by_name("Update outcome")
Givedrug= EncounterType.find_by_name("Give Drugs")
Preart = EncounterType.find_by_name("Pre ART visit")
Height = Concept.find_by_name("Height")
Concepts = Hash.new()
Visit_encounter_hash = Hash.new()

Use_queue = 1
Output_sql = 1
Execute_sql = 1
Patient_queue = Array.new
Patient_queue_size = 1000
Guardian_queue = Array.new
Guardian_queue_size = 1000
Hiv_reception_queue = Array.new
Hiv_reception_size = 1000
Hiv_first_visit_queue = Array.new
Hiv_first_visit_size = 1000
Height_weight_queue = Array.new
Height_weight_size = 1000
Hiv_staging_queue = Array.new
Hiv_stage_size = 1000
Art_visit_queue = Array.new
Art_visit_size = 1000
Update_outcome_queue = Array.new
Update_outcome_size = 1000
Give_drugs_queue = Array.new
Give_drugs_size = 1000
Pre_art_visit_queue = Array.new
Pre_art_visit_size = 1000
Users_queue = Array.new
Source_db= YAML.load(File.open(File.join(RAILS_ROOT, "config/database.yml"), "r"))['bart']["database"]


CONN = ActiveRecord::Base.connection


def start

  $visit_encounter_id = 1

  started_at = Time.now.strftime("%Y-%m-%d-%H%M%S")

  if Output_sql == 1
    $visits_outfile = File.open("./migration_export_visits-" + started_at + ".sql", "w")
    $pat_encounters_outfile = File.open("./migration_export_pat_encounters-" + started_at + ".sql", "w")
  end

  puts "Started at : #{Time.now}"
  t1 = Time.now
  Concept.find(:all).map do |con|
    Concepts[con.id] = con
  end
  t2 = Time.now
  elapsed = time_diff_milli t1, t2
  puts "Loaded concepts in #{elapsed}"

  patients = Patient.find_by_sql("Select * from #{Source_db}.patient limit 1000")
  count = patients.length
  puts "Number of patients to be migrated #{count}"

  total_enc = 0
  pat_enc = 0
  t1 = Time.now

  started_at = Time.now.strftime("%Y-%m-%d-%H%M%S")

  if Output_sql == 1
    $visits_outfile = File.open("./migration_export_visits-" + started_at + ".sql", "w")
    $pat_encounters_outfile = File.open("./migration_export_pat_encounters-" + started_at + ".sql", "w")
  end

  patients.each do |patient|
    puts "Working on patient with ID: #{patient.id}"
    pt1 = Time.now
    enc_type = ["HIV Reception", "HIV first visit", "Height/Weight",
                "HIV staging", "ART visit", "Update outcome",
                "Give drugs", "Pre ART visit"]

    enc_type.each do |enc_type|
      pat_id = patient["patient_id"]
      encounters = Encounter.find_by_sql("Select * from #{Source_db}.encounter where patient_id = #{pat_id} and encounter_type = #{self.get_encounter(enc_type)}")
      puts("#{encounters.length} encounters of type #{enc_type} found")
      encounters.each do |enc|
        total_enc +=1
        pat_enc +=1
        visit_encounter_id = self.check_for_visitdate(pat_id, enc.encounter_datetime.to_date)
        self.create_record(visit_encounter_id, enc)
      end
    end
    self.create_patient(patient)
    self.create_guardian(patient)
    pt2 = Time.now
    elapsed = time_diff_milli pt1, pt2
    eps = total_enc / elapsed
    puts "#{pat_enc} Encounters were processed in #{elapsed} for #{eps} eps"
    puts "#{count-=1}................ Patient(s) to go"
    pat_enc = 0
  end

  #Create system users
  self.create_users()

  # flush the queues
  flush_patient()
  flush_hiv_first_visit()
  flush_hiv_reception()
  flush_pre_art_visit_queue()
  flush_height_weight_queue()
  flush_give_drugs()
  flush_art_visit()
  flush_hiv_staging()
  flush_update_outcome()
  flush_users()
  flush_guardians()

  if Output_sql == 1
    $visits_outfile.close()
    $pat_encounters_outfile.close()
  end

  puts "Finished at : #{Time.now}"
  puts "#{total_enc} Encounters were processed"
  t2 = Time.now
  elapsed = time_diff_milli t1, t2
  eps = total_enc / elapsed
  puts "#{total_enc} Encounters were processed in #{elapsed} for #{eps} eps"

end


def time_diff_milli(start, finish)
  (finish - start)
end


def self.get_encounter(type)
  case type
    when 'ART visit'
      return Artvisit.id
    when 'HIV Reception'
      return Hivrecp.id
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


def self.check_for_visitdate(patient_id, encounter_date)
  # check if we have seen this patient visit and return the visit encounter id if we have
  if Visit_encounter_hash["#{patient_id}#{encounter_date}"] != nil
    return Visit_encounter_hash["#{patient_id}#{encounter_date}"]
  end

  # make a new visit encounter
  vdate = VisitEncounter.new()
  vdate.visit_date = encounter_date
  vdate.patient_id = patient_id

  # if executing sql utilize db to generate ids
  if Execute_sql == 1
    vdate.save
    Visit_encounter_hash["#{patient_id}#{encounter_date}"] = vdate.id
  else
    # generate an id internally
    Visit_encounter_hash["#{patient_id}#{encounter_date}"] = $visit_encounter_id
    # increment the counter
    $visit_encounter_id += 1
    # assign the id to the vdate object
    vdate.id = Visit_encounter_hash["#{patient_id}#{encounter_date}"]
  end

  if Output_sql == 1
    $visits_outfile << "INSERT INTO visit_encounters (id, patient_id, visit_date) VALUES (#{vdate.id}, #{patient_id}, '#{encounter_date}');\n"
  end

  return vdate.id
end

def preprocess_insert_val(val)

  # numbers returned as strings with no quotes
  if val.kind_of? Integer
    return val.to_s
  end

  # null values returned
  if val == nil || val == ""
    return "NULL"
  end

  # escape characters and return with quotes
  val = val.to_s.gsub("'", "''")
  return "'" + val + "'"
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
  patient.guardian_id = Relationship.find(:last, :conditions => ["person_id = ?", pat.id]).relative_id rescue nil
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

  if Use_queue > 0
    if Patient_queue[Patient_queue_size-1] == nil
      Patient_queue << patient
    else
      flush_patient()
      Patient_queue << patient
    end
  else
    patient.save()
  end

end

def self.create_guardian(pat)
  relatives = Relationship.find(:all, :conditions => ["person_id = ?", pat.id])
  (relatives || []).each do |relative|
    guardian = Guardian.new()
    temp_relative = Patient.find(:last, :conditions => ["patient_id = ? ", relative.relative_id])
    temp = PatientName.find(:last, :conditions => ["patient_id = ? and voided = 0", relative.relative_id])
    guardian.patient_id = pat.id
    guardian.family_name = temp.family_name rescue nil
    guardian.name = temp.given_name rescue nil
    guardian.gender = temp_relative.gender rescue nil
    guardian.relationship = RelationshipType.find(relative.relationship).name
    guardian.creator = temp_relative.creator rescue 1
    guardian.date_created = relative.date_created
    Guardian_queue << guardian
  end
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
        enc.agrees_to_follow_up = self.get_concept(ob.value_coded)
      when 'EVER RECEIVED ART'
        enc.ever_received_arv = self.get_concept(ob.value_coded)
      when 'EVER REGISTERED AT ART CLINIC'
        enc.ever_registered_at_art = self.get_concept(ob.value_coded)
      when 'LOCATION OF FIRST POSITIVE HIV TEST'
        enc.location_of_hiv_pos_test = Location.find(ob.value_numeric.to_i).name rescue 'Unknown'
      when 'DATE OF POSITIVE HIV TEST'
        enc.date_of_hiv_pos_test = ob.value_datetime
      when 'ARV NUMBER AT THAT SITE'
        enc.arv_number_at_that_site = ob.value_numeric
      when 'LOCATION OF ART INITIATION'
        enc.location_of_art_initiation = Location.find(ob.value_numeric.to_i).name rescue 'Unknown'
      when 'TAKEN ARVS IN LAST 2 MONTHS'
        enc.taken_arvs_in_last_two_months = self.get_concept(ob.value_coded)
      when 'LAST ARV DRUGS TAKEN'
        enc.last_arv_regimen = self.get_concept(ob.value_coded)
      when 'TAKEN ART IN LAST 2 WEEKS'
        enc.taken_arvs_in_last_two_weeks = self.get_concept(ob.value_coded)
      when 'HAS TRANSFER LETTER'
        enc.has_transfer_letter = self.get_concept(ob.value_coded)
      when 'SITE TRANSFERRED FROM'
        enc.site_transferred_from = Location.find(ob.value_numeric.to_i).name rescue 'Unknown'
      when 'DATE OF ART INITIATION'
        enc.date_of_art_initiation = ob.value_datetime
      when 'DATE LAST ARVS TAKEN'
        enc.date_last_arv_taken = ob.value_datetime
    end
  end

  # check if we are to utilize the queue
  if Use_queue > 0
    if Hiv_first_visit_queue[Hiv_first_visit_size-1] == nil
      Hiv_first_visit_queue << enc
    else
      flush_hiv_first_visit()
      Hiv_first_visit_queue << enc
    end
  else
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
      self.assign_drugs_dispensed(enc, drug_order, give_drugs_count)
      give_drugs_count+=1
    end
  end

  # check if we are to utilize the queue
  if Use_queue > 0
    if Give_drugs_queue[Give_drugs_size-1] == nil
      Give_drugs_queue << enc
    else
      flush_give_drugs()
      Give_drugs_queue << enc
    end
  else
    enc.save
  end

end


def self.assign_drugs_dispensed(encounter, drug_order, count)
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
  end
  encounter.drug_name5 = drug_order.drug.name
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
        enc.state = self.get_concept(ob.value_coded)
        enc.outcome_date = ob.obs_datetime
        if enc.state =='Transfer Out(With Transfer Note)'
          #enc.transferred_out_location
        end
    end
  end

  if Use_queue > 0
    if Update_outcome_queue[Update_outcome_size-1] == nil
      Update_outcome_queue << enc
    else
      flush_update_outcome()
      Update_outcome_queue << enc
    end
  else
    enc.save()
  end

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
  if enc.height == nil
    current_height = Observation.find(:last,
                                      :conditions => ["concept_id = ? and patient_id = ?", Height.id, encounter.patient_id]).value_numeric.to_i rescue nil
  else
    current_height = enc.height
  end
  enc.bmi = (enc.weight/(current_height*current_height)*10000) rescue nil

  if  Use_queue > 0
    if Height_weight_queue[Height_weight_size-1] == nil
      Height_weight_queue << enc
    else
      flush_height_weight_queue()
      Height_weight_queue << enc
    end
  else
    enc.save()
  end
end

def self.create_hiv_reception_record(visit_encounter_id, encounter)
  enc = HivReceptionEncounter.new()
  enc.patient_id = encounter.patient_id
  enc.visit_encounter_id = visit_encounter_id
  enc.date_created = encounter.date_created
  enc.creator = encounter.creator
  (encounter.observations || []).each do |ob|
    case ob.concept.name.upcase
      when 'GUARDIAN PRESENT'
        enc.guardian_present = self.get_concept(ob.value_coded)
      when 'PATIENT PRESENT'
        enc.patient_present = self.get_concept(ob.value_coded)
    end

  end
  if Use_queue > 0
    if Hiv_reception_queue[Hiv_reception_size-1] == nil
      Hiv_reception_queue << enc
    else
      flush_hiv_reception()
      Hiv_reception_queue << enc
    end
  else
    enc.save()
  end

end

def self.create_pre_art_record(visit_encounter_id, encounter)
  enc = PreArtVisitEncounter.new()
  enc.patient_id = encounter.patient_id
  enc.visit_encounter_id = visit_encounter_id
  enc.date_created = encounter.date_created
  enc.creator = encounter.creator
  (encounter.observations || []).each do |ob|
    self.repeated_obs(enc, ob) rescue nil
  end
  drug_induced_symptom (enc) rescue nil

  if Use_queue > 0
    if Pre_art_visit_queue[Pre_art_visit_size-1] == nil
      Pre_art_visit_queue << enc
    else
      flush_pre_art_visit_queue()
      Pre_art_visit_queue << enc
    end
  else
    enc.save()
  end

end

def self.assign_drugs_prescribed(enc, prescribed_drug_name_hash, prescribed_drug_dosage_hash, prescribed_drug_frequency_hash)
  count = 1
  (prescribed_drug_name_hash).each do |drug_name, name|
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

def self.assign_drugs_counted(encounter, obs, count)
  case count
    when 1
      encounter.drug_name_brought_to_clinic1 = Drug.find(obs.value_drug).name rescue nil
      encounter.drug_quantity_brought_to_clinic1 = obs.value_numeric rescue nil
    when 2
      encounter.drug_name_brought_to_clinic2 = Drug.find(obs.value_drug).name rescue nil
      encounter.drug_quantity_brought_to_clinic2 = obs.value_numeric rescue nil
    when 3
      encounter.drug_name_brought_to_clinic3 = Drug.find(obs.value_drug).name rescue nil
      encounter.drug_quantity_brought_to_clinic3 = obs.value_numeric rescue nil
    when 4
      encounter.drug_name_brought_to_clinic4 = Drug.find(obs.value_drug).name rescue nil
      encounter.drug_quantity_brought_to_clinic4 = obs.value_numeric rescue nil
  end
end

def self.assign_drugs_counted_but_not_brought(encounter, obs, count)
  case count
    when 1
      encounter.drug_left_at_home1 = obs.value_numeric rescue nil
    when 2
      encounter.drug_left_at_home2 = obs.value_numeric rescue nil
    when 3
      encounter.drug_left_at_home3 = obs.value_numeric rescue nil
    when 4
      encounter.drug_left_at_home4 = obs.value_numeric rescue nil
  end
end

def self.create_art_encounter(visit_encounter_id, encounter)
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
        self.assign_drugs_counted(enc, ob, drug_name_brought_to_clinic_count)
        drug_name_brought_to_clinic_count+=1
      when 'WHOLE TABLETS REMAINING BUT NOT BROUGHT TO CLINIC'
        self.assign_drugs_counted_but_not_brought(enc, ob, drug_name_not_brought_to_clinic_count)
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
      self.assign_drugs_prescribed(enc, prescribed_drug_name_hash, prescribed_drug_dosage_hash, prescribed_drug_frequency_hash)
    end
  end
  self.drug_induced_symptom(enc) rescue nil

  if Use_queue > 0
    if Art_visit_queue[Art_visit_size-1] == nil
      Art_visit_queue << enc
    else
      flush_art_visit()
      Art_visit_queue << enc
    end
  else
    enc.save()
  end

end

def self.create_hiv_staging_encounter(visit_encounter_id, encounter)
  startreason = PersonAttributeType.find_by_name("reason antiretrovirals started").person_attribute_type_id
  whostage = PersonAttributeType.find_by_name("WHO stage").person_attribute_type_id
  enc = HivStagingEncounter.new()
  enc.patient_id = encounter.patient_id
  enc.visit_encounter_id = visit_encounter_id
  enc.date_created = encounter.date_created
  enc.creator = encounter.creator
  enc.who_stage = PersonAttribute.find(:last, :conditions => ["person_id = ? 
    AND person_attribute_type_id = ?", encounter.patient_id, whostage]).value rescue nil
  enc.reason_for_starting_art = PersonAttribute.find(:last,
                                                     :conditions => ["person_id = ? AND person_attribute_type_id = ?",
                                                                     encounter.patient_id, startreason]).value rescue nil
  (encounter.observations || []).each do |ob|
    self.repeated_obs(enc, ob)
  end

  if Use_queue > 0
    if Hiv_staging_queue[Hiv_stage_size-1] == nil
      Hiv_staging_queue << enc
    else
      flush_hiv_staging()
      Hiv_staging_queue << enc
    end
  else
    enc.save()
  end


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
      enc.weight_loss = self.get_concept(ob.value_coded)
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
      enc.prescribe_cpt = self.get_concept(ob.value_coded)
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
    when 'PAROTID ENLARGEMENT, PERSISTENT UNEXPLAINED'
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
    when 'ORAL HAIRY LEUKOPLAKIA'
      enc.oral_hairy_leukoplakia =self.get_concept(ob.value_coded)
    when 'SEVERE WEIGHT LOSS >10% AND/OR BMI <18.5KG/M(SQUARED), UNEXPLAINED'
      enc.severe_weight_loss = self.get_concept(ob.value_coded)
    when 'FEVER, PERSISTENT UNEXPLAINED (INTERMITTENT OR CONSTANT, > 1 MONTH)'
      enc.fever_persistent_unexplained = self.get_concept(ob.value_coded)
    when 'PULMONARY TUBERCULOSIS (CURRENT)'
      enc.pulmonary_tuberculosis = self.get_concept(ob.value_coded)
    when 'PULMONARY TUBERCULOSIS WITHIN THE last 2 YEARS'
      enc.pulmonary_tuberculosis_last_2_years = self.get_concept(ob.value_coded)
    when 'SEVERE BACTERIAL INFECTIONS (PNEUMONIA, EMPYEMA, PYOMYOSITIS, BONE/JOINT, MENINGITIS, BACTERAEMIA)'
      enc.severe_bacterial_infection = self.get_concept(ob.value_coded)
    when 'BACTERIAL PNEUMONIA, RECURRENT SEVERE'
      enc.bacterial_pnuemonia = self.get_concept(ob.value_coded)
    when 'SYMPTOMATIC LYMPHOID INTERSTITIAL PNEUMONITIS'
      enc.symptomatic_lymphoid_interstitial_pnuemonitis = self.get_concept(ob.value_coded)
    when 'CHRONIC HIV-ASSOCIATED LUNG DISEASE INCLUDING BRONCHIECTASIS'
      enc.chronic_hiv_assoc_lung_disease = self.get_concept(ob.value_coded)
    when 'UNSPECIFIED STAGE 3 CONDITION'
      enc.unspecified_stage3_condition = self.get_concept(ob.value_coded)
    when 'ANAEMIA'
      enc.aneamia = self.get_concept(ob.value_coded)
    when 'NEUTROPAENIA, UNEXPLAINED < 500 /MM(CUBED)'
      enc.neutropaenia = self.get_concept(ob.value_coded)
    when 'THROMBOCYTOPAENIA, CHRONIC < 50,000 /MM(CUBED)'
      enc.thrombocytopaenia_chronic = self.get_concept(ob.value_coded)
    when 'DIARRHOEA'
      enc.diarhoea = self.get_concept(ob.value_coded)
    when 'ORAL CANDIDIASIS'
      enc.oral_candidiasis = self.get_concept(ob.value_coded)
    when 'ACUTE NECROTIZING ULCERATIVE GINGIVITIS OR PERIODONTITIS'
      enc.acute_necrotizing_ulcerative_gingivitis = self.get_concept(ob.value_coded)
    when 'LYMPH NODE TUBERCLOSIS'
      enc.lymph_node_tuberculosis = self.get_concept(ob.value_coded)
    when 'TOXOPLASMOSIS OF THE BRAIN'
      enc.toxoplasmosis_of_brain = self.get_concept(ob.value_coded)
    when 'CRYPTOCOCCAL MENINGITIS'
      enc.cryptococcal_meningitis = self.get_concept(ob.value_coded)
    when 'PROGRESSIVE MULTIFOCAL LEUKOENCEPHALOPATHY'
      enc.progressive_multifocal_leukoencephalopathy = self.get_concept(ob.value_coded)
    when 'DISSEMINATED MYCOSIS (COCCIDIOMYCOSIS OR HISTOPLASMOSIS)'
      enc.disseminated_mycosis = self.get_concept(ob.value_coded)
    when 'CANDIDIASIS OF OESOPHAGUS'
      enc.candidiasis_of_oesophagus = self.get_concept(ob.value_coded)
    when 'EXTRAPULMONARY TUBERCULOSIS'
      enc.extrapulmonary_tuberculosis = self.get_concept(ob.value_coded)
    when 'CEREBRAL OR B-CELL NON-HODGKIN LYMPHOMA'
      enc.cerebral_non_hodgkin_lymphoma = self.get_concept(ob.value_coded)
    when "KAPOSI'S SARCOMA"
      enc.kaposis = self.get_concept(ob.value_coded)
    when 'HIV ENCEPHALOPATHY'
      enc.hiv_encephalopathy = self.get_concept(ob.value_coded)
    when 'UNSPECIFIED STAGE 4 CONDITION'
      enc.unspecified_stage_4_condition = self.get_concept(ob.value_coded)
    when 'PNEUMOCYSTIS PNEUMONIA'
      enc.pnuemocystis_pnuemonia = self.get_concept(ob.value_coded)
    when 'DISSEMINATED NON-TUBERCLOSIS MYCOBACTERIAL INFECTION'
      enc.disseminated_non_tuberculosis_mycobactierial_infection = self.get_concept(ob.value_coded)
    when 'CRYPTOSPORIDIOSIS OR ISOSPORIASIS'
      enc.cryptosporidiosis = self.get_concept(ob.value_coded)
    when 'ISOSPORIASIS >1 MONTH'
      enc.isosporiasis = self.get_concept(ob.value_coded)
    when 'SYMPTOMATIC HIV-ASSOCIATED NEPHROPATHY OR CARDIOMYOPATHY'
      enc.symptomatic_hiv_asscoiated_nephropathy = self.get_concept(ob.value_coded)
    when 'CHRONIC HERPES SIMPLEX INFECTION(OROLABIAL, GENITAL / ANORECTAL >1 MONTH OR VISCERAL AT ANY SITE)'
      enc.chronic_herpes_simplex_infection = self.get_concept(ob.value_coded)
    when 'CYTOMEGALOVIRUS INFECTION (RETINITIS OR INFECTION OF OTHER ORGANS)'
      enc.cytomegalovirus_infection = self.get_concept(ob.value_coded)
    when 'TOXOPLASMOSIS OF THE BRAIN (FROM AGE 1 MONTH)'
      enc.toxoplasomis_of_the_brain_1month = self.get_concept(ob.value_coded)
    when 'RECTO-VAGINAL FISTULA, HIV-ASSOCIATED'
      enc.recto_vaginal_fitsula = self.get_concept(ob.value_coded)
    when 'REASON ANTIRETROVIRALS STARTED'
      enc.reason_for_starting_art = self.get_concept(ob.value_coded)
    when 'WHO STAGE'
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
  end rescue Concept.find_by_name('Missing').id
end

def preprocess_insert_val(val)

  # numbers returned as strings with no quotes
  if val.kind_of? Integer
    return val.to_s
  end

  # null values returned
  if val == nil || val == ""
    return "NULL"
  end

  # escape characters and return with quotes
  val = val.to_s.gsub("'", "''")
  return "'" + val + "'"
end

def flush_patient()

  flush_queue(Patient_queue, "patients", ['given_name', 'middle_name', 'family_name', 'gender', 'dob', 'dob_estimated', 'dead', 'traditional_authority', 'current_address', 'landmark', 'cellphone_number', 'home_phone_number', 'office_phone_number', 'occupation', 'nat_id', 'art_number', 'pre_art_number', 'tb_number', 'legacy_id', 'legacy_id2', 'legacy_id3', 'new_nat_id', 'prev_art_number', 'filing_number', 'archived_filing_number', 'voided', 'void_reason', 'date_voided', 'voided_by', 'date_created', 'creator'])

end

def flush_hiv_reception()

  flush_queue(Hiv_reception_queue, "hiv_reception_encounters", ['visit_encounter_id', 'patient_id', 'patient_present', 'guardian_present', 'date_created', 'creator'])

end


def flush_height_weight_queue()

  flush_queue(Height_weight_queue, "vitals_encounters", ['visit_encounter_id', 'patient_id', 'weight', 'height', 'bmi', 'date_created', 'creator'])

end

def flush_pre_art_visit_queue()

  flush_queue(Pre_art_visit_queue, "pre_art_visit_encounters", ['visit_encounter_id', 'patient_id', 'patient_pregnant', 'patient_breast_feeding', 'abdominal_pains', 'using_family_planning_method', 'family_planning_method_in_use', 'anorexia', 'cough', 'diarrhoea', 'fever', 'jaundice', 'leg_pain_numbness', 'vomit', 'weight_loss', 'peripheral_neuropathy', 'hepatitis', 'anaemia', 'lactic_acidosis', 'lipodystrophy', 'skin_rash', 'drug_induced_abdominal_pains', 'drug_induced_anorexia', 'drug_induced_diarrhoea', 'drug_induced_jaundice', 'drug_induced_leg_pain_numbness', 'drug_induced_vomit', 'drug_induced_peripheral_neuropathy', 'drug_induced_hepatitis', 'drug_induced_anaemia', 'drug_induced_lactic_acidosis', 'drug_induced_lipodystrophy', 'drug_induced_skin_rash', 'drug_induced_other_symptom', 'tb_status', 'refer_to_clinician', 'prescribe_cpt', 'prescription_duration', 'number_of_condoms_given', 'prescribe_ipt', 'date_created', 'creator'])

end

def flush_hiv_first_visit

  flush_queue(Hiv_first_visit_queue, "first_visit_encounters", ['visit_encounter_id', 'patient_id', 'agrees_to_follow_up', 'date_of_hiv_pos_test', 'date_of_hiv_pos_test_estimated', 'location_of_hiv_pos_test', 'arv_number_at_that_site', 'location_of_art_initiation', 'taken_arvs_in_last_two_months', 'taken_arvs_in_last_two_weeks', 'has_transfer_letter', 'site_transferred_from', 'date_of_art_initiation', 'ever_registered_at_art', 'ever_received_arv', 'last_arv_regimen', 'date_last_arv_taken', 'date_last_arv_taken_estimated', 'voided', 'void_reason', 'date_voided', 'voided_by', 'date_created', 'creator'])

end

def flush_give_drugs()

  flush_queue(Give_drugs_queue, "give_drugs_encounters", ['visit_encounter_id', 'patient_id', 'drug_name1', 'dispensed_quantity1', 'drug_name2', 'dispensed_quantity2', 'drug_name3', 'dispensed_quantity3', 'drug_name4', 'dispensed_quantity4', 'drug_name5', 'dispensed_quantity5', 'voided', 'void_reason', 'date_voided', 'voided_by', 'date_created', 'creator'])

end


def flush_hiv_first_visit

  flush_queue(Hiv_first_visit_queue, "first_visit_encounters", ['visit_encounter_id', 'patient_id', 'agrees_to_follow_up', 'date_of_hiv_pos_test', 'date_of_hiv_pos_test_estimated', 'location_of_hiv_pos_test', 'arv_number_at_that_site', 'location_of_art_initiation', 'taken_arvs_in_last_two_months', 'taken_arvs_in_last_two_weeks', 'has_transfer_letter', 'site_transferred_from', 'date_of_art_initiation', 'ever_registered_at_art', 'ever_received_arv', 'last_arv_regimen', 'date_last_arv_taken', 'date_last_arv_taken_estimated', 'voided', 'void_reason', 'date_voided', 'voided_by', 'date_created', 'creator'])

end

def flush_art_visit()

  flush_queue(Art_visit_queue, "art_visit_encounters", ['visit_encounter_id', 'patient_id', 'patient_pregnant', 'patient_breast_feeding', 'using_family_planning_method', 'family_planning_method_used', 'abdominal_pains', 'anorexia', 'cough', 'diarrhoea', 'fever', 'jaundice', 'leg_pain_numbness', 'vomit', 'weight_loss', 'peripheral_neuropathy', 'hepatitis', 'anaemia', 'lactic_acidosis', 'lipodystrophy', 'skin_rash', 'other_symptoms', 'drug_induced_Abdominal_pains', 'drug_induced_anorexia', 'drug_induced_diarrhoea', 'drug_induced_jaundice', 'drug_induced_leg_pain_numbness', 'drug_induced_vomit', 'drug_induced_peripheral_neuropathy', 'drug_induced_hepatitis', 'drug_induced_anaemia', 'drug_induced_lactic_acidosis', 'drug_induced_lipodystrophy', 'drug_induced_skin_rash', 'drug_induced_other_symptom', 'tb_status', 'refer_to_clinician', 'prescribe_arv', 'drug_name_brought_to_clinic1', 'drug_quantity_brought_to_clinic1', 'drug_left_at_home1', 'drug_name_brought_to_clinic2', 'drug_quantity_brought_to_clinic2', 'drug_left_at_home2', 'drug_name_brought_to_clinic3', 'drug_quantity_brought_to_clinic3', 'drug_left_at_home3', 'drug_name_brought_to_clinic4', 'drug_quantity_brought_to_clinic4', 'drug_left_at_home4', 'arv_regimen', 'drug1', 'dosage1', 'frequency1', 'drug2', 'dosage2', 'frequency2', 'drug3', 'dosage3', 'frequency3', 'drug4', 'dosage4', 'frequency4', 'prescription_duration', 'prescribe_cpt', 'number_of_condoms_given', 'depo_provera_given', 'continue_treatment_at_clinic', 'voided', 'void_reason', 'date_voided', 'voided_by', 'date_created', 'creator'])

end

def flush_hiv_staging()

  flush_queue(Hiv_staging_queue, "hiv_staging_encounters", ['visit_encounter_id', 'patient_id', 'patient_pregnant', 'patient_breast_feeding', 'cd4_count_available', 'cd4_count', 'cd4_count_modifier', 'cd4_count_percentage', 'date_of_cd4_count', 'asymptomatic', 'persistent_generalized_lymphadenopathy', 'unspecified_stage_1_cond', 'molluscumm_contagiosum', 'wart_virus_infection_extensive', 'oral_ulcerations_recurrent', 'parotid_enlargement_persistent_unexplained', 'lineal_gingival_erythema', 'herpes_zoster', 'respiratory_tract_infections_recurrent', 'unspecified_stage2_condition', 'angular_chelitis', 'papular_prurtic_eruptions', 'hepatosplenomegaly_unexplained', 'oral_hairy_leukoplakia', 'severe_weight_loss', 'fever_persistent_unexplained', 'pulmonary_tuberculosis', 'pulmonary_tuberculosis_last_2_years', 'severe_bacterial_infection', 'bacterial_pnuemonia', 'symptomatic_lymphoid_interstitial_pnuemonitis', 'chronic_hiv_assoc_lung_disease', 'unspecified_stage3_condition', 'aneamia', 'neutropaenia', 'thrombocytopaenia_chronic', 'diarhoea', 'oral_candidiasis', 'acute_necrotizing_ulcerative_gingivitis', 'lymph_node_tuberculosis', 'toxoplasmosis_of_brain', 'cryptococcal_meningitis', 'progressive_multifocal_leukoencephalopathy', 'disseminated_mycosis', 'candidiasis_of_oesophagus', 'extrapulmonary_tuberculosis', 'cerebral_non_hodgkin_lymphoma', 'kaposis', 'hiv_encephalopathy', 'bacterial_infections_severe_recurrent', 'unspecified_stage_4_condition', 'pnuemocystis_pnuemonia', 'disseminated_non_tuberculosis_mycobactierial_infection', 'cryptosporidiosis', 'isosporiasis', 'symptomatic_hiv_asscoiated_nephropathy', 'chronic_herpes_simplex_infection', 'cytomegalovirus_infection', 'toxoplasomis_of_the_brain_1month', 'recto_vaginal_fitsula', 'reason_for_starting_art', 'who_stage', 'voided', 'void_reason', 'date_voided', 'voided_by', 'date_created', 'creator'])

end

def flush_update_outcome()

  flush_queue(Update_outcome_queue, "outcome_encounters", ['visit_encounter_id', 'patient_id', 'state', 'outcome_date', 'transferred_out_location', 'voided', 'void_reason', 'date_voided', 'voided_by', 'date_created', 'creator'])

end

def flush_users()
  flush_queue(Users_queue, 'users', ['username', 'first_name', 'middle_name', 'last_name', 'password', 'salt', 'date_created', 'voided', 'void_reason', 'date_voided', 'voided_by', 'creator'])
end

def flush_guardians()
  flush_queue(Guardian_queue, "guardians", ['patient_id', 'family_name', 'name', 'gender', 'relationship', 'creator', 'date_created'])
end


def flush_queue(queue, table, columns)
  if queue.length == 0
    return
  end

  insert_vals = columns

  inserts = []

  queue.each { |e|
    i = ("(")
    insert_vals.each { |insert_val|
      i += preprocess_insert_val(eval("e.#{insert_val}"))
      i += ", "
    }
    # remove last comma space before appending the end parenthesis
    i = i.chop.chop
    i += ")"
    inserts << i
  }

  sql = "INSERT INTO #{table} (#{insert_vals.join(", ")}) VALUES #{inserts.join(", ")}"

  if Output_sql == 1
    $pat_encounters_outfile << sql + ";\n"
  end

  if Execute_sql == 1
    CONN.execute sql
  end

  queue.clear()
end


def self.create_users()
  users = User.find_by_sql("Select* from  #{Source_db}.users")

  users.each do |user|
    new_user = MigratedUsers.new()
    new_user.username = user.username
    new_user.first_name = user.first_name
    new_user.middle_name = user.middle_name
    new_user.last_name = user.last_name
    new_user.password = user.password
    new_user.salt = user.salt
    new_user.date_created = user.date_created
    new_user.voided = user.voided
    new_user.void_reason = user.void_reason
    new_user.date_voided = user.date_voided
    new_user.voided_by = user.voided_by
    new_user.creator = user.creator
    Users_queue << new_user
  end
end

start

