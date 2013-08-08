require 'mysql'

$mysql_conn = Mysql.new(ARGV[0], ARGV[1], ARGV[2],ARGV[3])
$enc_id = 1
$outcome_id = 1

def start
  count = 1
  patients =  $mysql_conn.query("SELECT * FROM tbpatient")
  patients.each do |row|
    puts "Working with patient #{count}"
    create_patient(row)

    followups = $mysql_conn.query("SELECT * FROM tbfollowup WHERE FdxReferencePatient = #{row[0]} AND FdxReferenceProgram
                                   IN (167,168,169,379,380,381) ORDER BY FddVisit ASC")
    first_followup = true
    followups.each do |followup_visit|

      if first_followup
        create_hiv_first_visit_enc(row, followup_visit)
        create_hiv_staging_enc(row, followup_visit)
        first_followup = false
      end

      if pre_art_patient(row[0], followup_visit[9])
        create_pre_art_visit_enc(row, followup_visit)
      else
        create_art_visit_enc(row, followup_visit)
      end

      create_vitals_enc(followup_visit)
      create_hiv_recp_enc(followup_visit)
      create_give_drugs_encounters(row, followup_visit)

    end
    create_patient_outcomes(row)
    count +=1
  end

  fix()

end

def create_patient(patient_array)
  puts "Creating patient"
  patient = PatientRecord.new()
  patient.patient_id = patient_array[0]
  patient.given_name = patient_array[9].split(" ")[0]
  patient.middle_name = nil
  patient.family_name = patient_array[9].split(" ")[1] rescue nil
  patient.gender = patient_array[10] == "0" ? "Male" : "Female"
  patient.dob = get_dob(patient_array)
  patient.dob_estimated = patient_array[12].nil? ? false : true
  patient.current_address = $mysql_conn.query("SELECT FdsLookup FROM tbreference WHERE FdxReference = #{patient_array[3]}").fetch_row[0]
  patient.occupation= $mysql_conn.query("SELECT FdsLookup FROM tbreference WHERE FdxReference = #{patient_array[5]}").fetch_row[0]
  patient.dead = patient_array[22] == "-1" ? true : false
  patient.art_number= patient_array[8]
=begin
  patient.traditional_authority = ids["ta"]
  patient.landmark = ids["phy_add"]
  patient.cellphone_number= ids["cell"]
  patient.home_phone_number= ids["home_phone"]
  patient.office_phone_number= ids["office_phone"]
  patient.nat_id = ni
  patient.pre_art_number= ids["pre_arv_number"]
  patient.tb_number= ids["tb_id"]
  patient.new_nat_id= ids["new_nat_id"]
  patient.prev_art_number= ids["pre_arv_number"]
  patient.filing_number= ids["filing_number"]
  patient.archived_filing_number= ids["archived_filing_number"]
=end
  patient.void_reason = nil
  patient.date_voided = nil
  patient.voided_by = nil
  patient.date_created = patient_array[1]
  patient.creator = 1
  patient.save
end

def create_vitals_enc(follow_up_enc)

  vitals = VitalsEncounter.new
  vitals.visit_encounter_id = check_for_visit_date(follow_up_enc[3], follow_up_enc[9])
  vitals.old_enc_id = $enc_id
  vitals.patient_id = follow_up_enc[3]
  vitals.encounter_datetime = follow_up_enc[9]
  vitals.date_created = follow_up_enc[1]
  vitals.weight = follow_up_enc[21].round(2) rescue nil
  vitals.height = follow_up_enc[22].round(2) rescue nil
  vitals.creator = 1

  if vitals.height.blank?
     current_height = $mysql_conn.query("SELECT FdnHeight FROM tbfollowup WHERE FdxReferencePatient= #{follow_up_enc[3]}
        AND DATE(FddVisit) <= DATE('#{follow_up_enc[9].to_s}') ORDER BY FddVisit DESC LIMIT 1 ").fetch_row
  else
    current_height = vitals.height
  end

  vitals.bmi = (vitals.weight/(current_height*current_height)*10000).round(2) rescue nil

  vitals.save
  $enc_id +=1
end

def create_hiv_recp_enc(follow_up_enc)
  puts "creating hiv reception encounter"
  enc = HivReceptionEncounter.new()
  enc.patient_id = follow_up_enc[3]
  enc.visit_encounter_id = check_for_visit_date(follow_up_enc[3], follow_up_enc[9])
  enc.old_enc_id = $enc_id
  enc.location = "Thyolo District Hospital"
  enc.date_created = follow_up_enc[1]
  enc.encounter_datetime = follow_up_enc[9]
  enc.creator = 1
  enc.patient_present = "Yes"
  enc.save

  $enc_id +=1
end

def create_hiv_first_visit_enc(patient_data, visit_data)

  puts "creating hiv first visit encounter"
  transfer_in = patient_data[14] == "-1" ? true : false
  enc = FirstVisitEncounter.new()
  enc.patient_id = patient_data[0]
  enc.location = "Thyolo District Hospital"
  enc.visit_encounter_id = check_for_visit_date(visit_data[3], visit_data[9])
  enc.date_created = visit_data[1]
  enc.encounter_datetime = visit_data[9]
  enc.old_enc_id = $enc_id
  enc.creator = 1
  enc.agrees_to_follow_up = visit_data[10].blank? ? "No" : "Yes"
  enc.ever_received_arv = check_if_ever_received_art(patient_data[0])
  enc.ever_registered_at_art = (transfer_in == true || enc.ever_received_arv == "Yes") ? "Yes" : "No"
  enc.location_of_hiv_pos_test = 'Unknown'
  enc.date_of_hiv_pos_test = patient_data[19]
  enc.arv_number_at_that_site = patient_data[8]

  #enc.taken_arvs_in_last_two_months = self.get_concept(ob.value_coded)

  #enc.taken_arvs_in_last_two_weeks = self.get_concept(ob.value_coded)

 # enc.date_last_arv_taken = ob.value_datetime
  enc.weight = visit_data[21]
  enc.height = visit_data[22]
  enc.bmi = (enc.weight/(enc.height*enc.height)*10000) rescue nil

  if transfer_in
    enc.has_transfer_letter = "Yes"
    enc.location_of_art_initiation = 'Unknown'
    enc.site_transferred_from = 'Unknown'
    enc.last_arv_regimen = $mysql_conn.query("SELECT FdsLookup FROM tbreference WHERE Fdxreference IN (SELECT
                                          FdxReferenceDrug FROM tbpatientdrug WHERE MAX(FddBeginning) AND
                                          FdxReferencePatient = #{patient_data[0]} LIMIT 1)").fetch_row.to_date rescue nil

    enc.date_of_art_initiation = $mysql_conn.query("SELECT MIN(FddBeginning) FROM tbpatientdrug WHERE
                                                  FdxReferencePatient = #{patient_data[0]}").fetch_row.to_date rescue nil
  end

  enc.save
  $enc_id +=1
end

def  create_patient_outcomes(init_patient_data)

  visit_id =  self.check_for_visit_date(init_patient_data[0],init_patient_data[2])
  if init_patient_data[22] == "-1"

    pat_outcome = PatientOutcome.new()

    pat_outcome.visit_encounter_id = visit_id
    pat_outcome.outcome_id = $outcome_id
    pat_outcome.patient_id = init_patient_data[0]
    pat_outcome.outcome_state = "Died"
    pat_outcome.outcome_date = init_patient_data[23]
    pat_outcome.save!
    $outcome_id += 1
  end

  if init_patient_data[13] == "-1"
    pat_outcome = PatientOutcome.new()

    pat_outcome.visit_encounter_id = visit_id
    pat_outcome.outcome_id = $outcome_id
    pat_outcome.patient_id = init_patient_data[0]
    pat_outcome.outcome_state = "Transfer Out(With Transfer Note)"
    pat_outcome.outcome_date = init_patient_data[15]
    pat_outcome.save!
    $outcome_id += 1
  end

end

def create_hiv_staging_enc(patient_data, visit_data)

  puts "creating hiv staging encounter"
  diagnosis = $mysql_conn.query("SELECT * FROM tbpatientdiagnosis WHERE FdxReferencePatient = #{patient_data[0]}")

  if diagnosis.num_rows > 0

    enc = HivStagingEncounter.new()
    enc.patient_id = patient_data[0]
    enc.old_enc_id = $enc_id
    enc.visit_encounter_id = self.check_for_visit_date(patient_data[0],patient_data[1])
    enc.location = "Thyolo District Hospital"
    enc.date_created = patient_data[1]
    enc.encounter_datetime = visit_data[9]
    enc.creator = 1
    enc.who_stage = "WHO stage " + patient_data[38].to_s rescue nil
    enc.reason_for_starting_art = reason_for_starting_arv(patient_data, enc, visit_data[20] )
    enc.cd4_count = visit_data[19]
    enc.date_of_cd4_count = visit_data[14]
    diagnosis.each do |ob|
      self.repeated_obs_staging(enc, ob[4])
    end
    enc.save
    $enc_id +=1
    #reason_for_starting_arv(patient_data, enc)
  end

end

def create_art_visit_enc(patient_data, visit_data)

  puts "Creating art visit encounter"
  enc = ArtVisitEncounter.new()
  enc.patient_id = patient_data[0]
  enc.visit_encounter_id = self.check_for_visit_date(patient_data[0],visit_data[9])
  enc.old_enc_id = $enc_id
  enc.date_created = visit_data[1]
  enc.encounter_datetime = visit_data[9]
  enc.creator = 1
  enc.location = "Thyolo District Hospital"
  enc.tb_status = check_if_patient_has_tb(patient_data[0], visit_data[9], visit_data[13])
  enc.prescribe_cpt = $mysql_conn.query("SELECT * FROM tbfollowupdrug WHERE FdxReferenceFollowUp = #{visit_data[0]}
                                          AND FdxReferenceDrug IN (56,148)").num_rows > 0 ? "Yes" : "No"
  enc.prescribe_arv = $mysql_conn.query("SELECT * FROM tbfollowupdrug WHERE FdxReferenceFollowUp = #{visit_data[0]}
                                          AND FdxReferenceDrug NOT IN (56,148,57,58, 211)").num_rows > 0 ? "Yes" : "No"
  drugs = $mysql_conn.query("SELECT * FROM tbfollowupdrug WHERE FdxReferenceFollowUp = #{visit_data[0]}")

  drugs.each do |dispensed_drug|

    self.drug_induced_symptom(enc, dispensed_drug[5] )
    self.drug_induced_symptom(enc, dispensed_drug[6] )

  end

  if !drugs.blank?
    create_patient_outcome(patient_data[0], "On ART", visit_data[9])
  end

  last_visit = $mysql_conn.query("SELECT * FROM tbfollowupdrug WHERE FdxReferenceFollowUp =
                                  (SELECT FdxReference FROM tbfollowup WHERE FdxReferencePatient = #{patient_data[0]} AND
                                  FddVisit < '#{visit_data[9]}' ORDER BY FddVisit DESC LIMIT 1)")

  unless visit_data[34].blank?
    i = 1

    last_visit.each do |dispensed|

      drug_detail = $mysql_conn.query("SELECT * FROM drug_map WHERE FdxReference = #{dispensed[4]}").fetch_row

      case i
        when 1

          enc.drug_name_brought_to_clinic1 = drug_detail[5] rescue nil
          enc.drug_quantity_brought_to_clinic1 =  get_brought(amount_dispensed(drug_detail[10], (visit_data[10].to_date - visit_data[9].to_date).to_i),   visit_data[34]) rescue nil

          enc.drug_left_at_home1 = nil
        when 2
          enc.drug_name_brought_to_clinic2 = drug_detail[5] rescue nil
          enc.drug_quantity_brought_to_clinic2 =  get_brought(amount_dispensed(drug_detail[10], (visit_data[10].to_date - visit_data[9].to_date).to_i),   visit_data[34]) rescue nil

          enc.drug_left_at_home1 = nil
        when 3
          enc.drug_name_brought_to_clinic3 = drug_detail[5] rescue nil
          enc.drug_quantity_brought_to_clinic3 = get_brought(amount_dispensed(drug_detail[10], (visit_data[10].to_date - visit_data[9].to_date).to_i),   visit_data[34]) rescue nil

          enc.drug_left_at_home1 = nil
        when 4
          enc.drug_name_brought_to_clinic4 = drug_detail[5] rescue nil
          enc.drug_quantity_brought_to_clinic4 = get_brought(amount_dispensed(drug_detail[10], (visit_data[10].to_date - visit_data[9].to_date).to_i),   visit_data[34]) rescue nil

          enc.drug_left_at_home1 = nil
      end
      i +=1
    end

  end


  if ((enc.prescribe_arv == "Yes") || (enc.prescribe_cpt == "Yes")) && (!visit_data[10].blank?)
    enc.continue_art = "Yes"
    enc.continue_treatment_at_clinic = "Yes"
  else
    enc.continue_art = "No"
    enc.continue_treatment_at_clinic = "No"
  end

  diagnosis = $mysql_conn.query("SELECT * FROM tbfollowupdiagnosis WHERE FdxReferenceFollowUp = #{visit_data[0]}")
  diagnosis.each do |ob|
    self.repeated_obs(enc, ob[4])
  end

  enc.save()
  $enc_id +=1

end

def create_pre_art_visit_enc(patient_details, visit_data)

  puts "creating pre-art visit encounter"
  enc = PreArtVisitEncounter.new()
  enc.patient_id = patient_details[0]
  enc.location = "Thyolo District Hospital"
  enc.visit_encounter_id = self.check_for_visit_date(patient_details[0], visit_data[9])
  enc.old_enc_id = $enc_id
  enc.date_created = visit_data[1]
  enc.encounter_datetime = visit_data[9]
  enc.creator = 1
  enc.prescription_duration = (visit_data[10].to_date - visit_data[9].to_date).to_i rescue nil
  enc.tb_status = check_if_patient_has_tb(patient_details[0], visit_data[9], visit_data[13])
  enc.prescribe_cpt = $mysql_conn.query("SELECT * FROM tbfollowupdrug WHERE FdxReferenceFollowUp = #{visit_data[0]}
                                          AND FdxReferenceDrug IN (56,148)").num_rows > 0 ? "Yes" : "No"
  enc.prescribe_ipt= $mysql_conn.query("SELECT * FROM tbfollowupdrug WHERE FdxReferenceFollowUp = #{visit_data[0]}
                                          AND FdxReferenceDrug IN (59,151)").num_rows > 0 ? "Yes" : "No"
  diagnosis = $mysql_conn.query("SELECT * FROM tbfollowupdiagnosis WHERE FdxReferenceFollowUp = #{visit_data[0]}")
  diagnosis.each do |ob|
    self.repeated_obs(enc, ob[4])
  end

  drugs = $mysql_conn.query("SELECT FdxReferenceIntolerance02, FdxReferenceIntolerance01 FROM tbfollowupdrug WHERE FdxReferenceFollowUp = #{visit_data[0]}")

  drugs.each do |dispensed_drug|


    self.drug_induced_symptom(enc, dispensed_drug[1])
    self.drug_induced_symptom(enc, dispensed_drug[0])


  end
  create_patient_outcome(patient_details[0], "Never Started ART", visit_data[9])
  enc.save
  $enc_id += 1
end

def create_give_drugs_encounters(patient_data, visit_data)

  drugs = $mysql_conn.query("SELECT * FROM tbfollowupdrug WHERE FdxReferenceFollowUp = #{visit_data[0]}")

  if drugs.num_rows > 0

    puts "Creating give drugs encounter, reference #{visit_data[0]}"
    enc = GiveDrugsEncounter.new()
    enc.patient_id = patient_data[0]
    enc.visit_encounter_id = self.check_for_visit_date(patient_data[0],visit_data[9])
    enc.old_enc_id = $enc_id
    enc.location = "Thyolo District Hospital"
    enc.date_created = visit_data[1]
    enc.encounter_datetime = visit_data[9]
    enc.prescription_duration =  durations((visit_data[10].to_date - visit_data[9].to_date).to_i) rescue nil
    enc.appointment_date = visit_data[10]
    enc.creator = 1


    count = 1
    drugs.each do |drug|

      drug_detail = $mysql_conn.query("SELECT * FROM drug_map WHERE FdxReference = #{drug[4]}").fetch_row

      if ![148, 57,58, 211].include? drug[4]

        enc.regimen_category = drug_detail[12]
      end

      case count
        when 1
          enc.pres_drug_name1 = drug_detail[5] rescue nil
          enc.pres_dosage1 = drug_detail[10]
          enc.pres_frequency1= "Evening-Noon-Night-Morning"
          enc.dispensed_quantity1 = amount_dispensed(drug[10], (visit_data[10].to_date - visit_data[9].to_date).to_i ) rescue nil
          enc.dispensed_drug_name1 = enc.pres_drug_name1
          enc.dispensed_dosage1 = drug_detail[10]

        when 2
          enc.pres_drug_name2 = drug_detail[5] rescue nil
          enc.pres_dosage2 = drug_detail[10]
          enc.pres_frequency2= "Evening-Noon-Night-Morning"
          enc.dispensed_quantity2 = amount_dispensed(drug[10], (visit_data[10].to_date - visit_data[9].to_date).to_i ) rescue nil
          enc.dispensed_drug_name2 = enc.pres_drug_name1
          enc.dispensed_dosage2 = drug_detail[10]

        when 3
          enc.pres_drug_name3 = drug_detail[5] rescue nil
          enc.pres_dosage3 = drug[10]
          enc.pres_frequency3= "Evening-Noon-Night-Morning"
          enc.dispensed_quantity3 = amount_dispensed(drug[10], (visit_data[10].to_date - visit_data[9].to_date).to_i ) rescue nil
          enc.dispensed_drug_name3 = enc.pres_drug_name1
          enc.dispensed_dosage3 = drug[10]

        when 4
          enc.pres_drug_name4 = drug_detail[5] rescue nil
          enc.pres_dosage4 = drug[10]
          enc.pres_frequency4= "Evening-Noon-Night-Morning"
          enc.dispensed_quantity4 = amount_dispensed(drug[10], (visit_data[10].to_date - visit_data[9].to_date).to_i ) rescue nil
          enc.dispensed_drug_name4 = enc.pres_drug_name4
          enc.dispensed_dosage4 = drug[10]

        when 5
          enc.pres_drug_name5 = drug_detail[5] rescue nil
          enc.pres_dosage5 = drug[10]
          enc.pres_frequency5= "Evening-Noon-Night-Morning"
          enc.dispensed_quantity5 = amount_dispensed(drug[10], (visit_data[10].to_date - visit_data[9].to_date).to_i ) rescue nil
          enc.dispensed_drug_name5 = enc.pres_drug_name5
          enc.dispensed_dosage5 = drug[10]

      end


    end

    enc.save
    $enc_id +=1


  end


end

def self.check_for_visit_date(patient_id, encounter_date)
  # check if we have seen this patient visit and return the visit encounter id if we have

   exists = VisitEncounter.find(:first, :conditions => ["visit_date = ? AND patient_id = ?", encounter_date, patient_id]).id rescue nil

  # make a new visit encounter
  if exists.blank?
    vdate = VisitEncounter.new()
    vdate.visit_date = encounter_date
    vdate.patient_id = patient_id
    vdate.save
    exists = vdate.id
  end

  return exists
end

def get_dob_esitmated(age,  date_estimated)

  year = date_estimated.to_date.year.to_i - age.to_i

  return "01/01/"+year.to_s

end

def check_if_ever_received_art(patient_id)

  check = $mysql_conn.query("SELECT * FROM tbpatientdrug WHERE FdxReferencePatient = #{patient_id}")

  if check.num_rows > 0
    return "Yes"
  else
    return "No"
  end

end

def self.repeated_obs(enc,ob)
  case $mysql_conn.query("SELECT FdsLookup FROM tbreference WHERE FdxReference = #{ob}").fetch_row.to_s.upcase
    when 'PANCREATIC AMYLASE (>2-5 x ULN) AND ABDOMINAL PAIN'
      enc.abdominal_pains = "Yes"
    when 'ANOREXIA'
      enc.anorexia = "Yes"
    when 'COUGH'
      enc.cough = "Yes"
    when 'DIARRHOEA'
      enc.diarrhoea = "Yes"
    when 'FEVER, UNEXPLAINED'
      enc.fever = "Yes"
    when 'JAUNDICE'
      enc.jaundice = "Yes"
    when 'LEG PAIN / NUMBNESS'
      enc.leg_pain_numbness = "Yes"
    when 'VOMIT'
      enc.vomit = "Yes"
    when 'WEIGHT LOSS <10%'
      enc.weight_loss = "Yes"
    when 'HEPATITIS'
      enc.hepatitis = "Yes"
    when 'Anemia 1-2 (Hb 7-9.4)'
      enc.anaemia = "Yes"
    when 'Anemia 3 (Hb 6.5-6.9)'
      enc.anaemia = "Yes"
    when 'Anemia 4 (Hb <6.5)'
      enc.anaemia = "Yes"
    when 'LACTIC ACIDOSIS'
      enc.lactic_acidosis = "Yes"
    when 'LIPODYSTROPHY'
      enc.lipodystrophy = "Yes"
    when 'SKIN RASH'
      enc.skin_rash = "Yes"
    when 'PERIPHERAL NEUROPATHY'
      enc.peripheral_neuropathy = "Yes"

  end
end
def self.repeated_obs_staging(enc, ob)

  case $mysql_conn.query("SELECT FdsLookup FROM tbreference WHERE FdxReference = #{ob}").fetch_row.to_s.upcase

    when 'PANCREATIC AMYLASE (>2-5 x ULN) AND ABDOMINAL PAIN'
      enc.abdominal_pains = "Yes"
    when 'ANOREXIA'
      enc.anorexia = "Yes"
    when 'COUGH'
      enc.cough = "Yes"
    when 'DIARRHOEA'
      enc.diarrhoea = "Yes"
    when 'FEVER, UNEXPLAINED'
      enc.fever_persistent_unexplained = "Yes"
    when 'JAUNDICE'
      enc.jaundice = "Yes"
    when 'LEG PAIN / NUMBNESS'
      enc.leg_pain_numbness = "Yes"
    when 'VOMIT'
      enc.vomit = "Yes"
    when 'WEIGHT LOSS <10%'
      enc.severe_weight_loss = "Yes"
    when 'OTHER SYMPTOM'
      enc.other_symptoms = "Yes"
    when 'PERIPHERAL NEUROPATHY'
      enc.peripheral_neuropathy = "Yes"
    when 'HEPATITIS'
      enc.hepatitis = "Yes"
    when 'ANAEMIA'
      enc.anaemia = "Yes"
    when 'LACTIC ACIDOSIS'
      enc.lactic_acidosis = "Yes"
    when 'LIPODYSTROPHY'
      enc.lipodystrophy = "Yes"
    when 'SKIN RASH'
      enc.skin_rash = "Yes"
    when 'ASYMPTOMATIC'
      enc.asymptomatic = "Yes"
    when 'PERSISTENT GENERALIZED LYMPHADENOPATHY'
      enc.persistent_generalized_lymphadenopathy = "Yes"
    when 'MOLLUSCUM CONTAGIOSUM'
      enc.molluscumm_contagiosum = "Yes"
    when 'WART INFECTION'
      enc.wart_virus_infection_extensive = "Yes"
    when 'ORAL ULCERATIONS'
      enc.oral_ulcerations_recurrent = "Yes"
    when 'UNEXPLAINED PAROTID ENLARGEMENT'
      enc.parotid_enlargement_persistent_unexplained = "Yes"
    when 'LINEAL GINGIVAL ERYTHEMA'
      enc.lineal_gingival_erythema = "Yes"
    when 'HERPES ZOSTER'
      enc.herpes_zoster = "Yes"
    when 'RESPIRATORY TRACT INFECTIONS, RECURRENT(SINUSITIS, TONSILLITIS, OTITIS MEDIA, PHARYNGITIS)'
      enc.respiratory_tract_infections_recurrent = "Yes"
    when 'ANGULAR CHEILITIS'
      enc.angular_chelitis = "Yes"
    when 'FUNGAL NAIL INFECTION'
      enc.papular_prurtic_eruptions = "Yes"
    when 'PAPULAR PRUTIC ERUPTION'
      enc.papular_prurtic_eruptions = "Yes"
    when 'UNEXPLAINED HEPATOSPLENOMEGALY'
      enc.hepatosplenomegaly_unexplained = "Yes"
    when 'ORAL HAIRY LEUKOPLAKIA'
      enc.oral_hairy_leukoplakia ="Yes"
    when 'WEIGHT LOSS >10%'
      enc.severe_weight_loss = "Yes"
    when 'FEVER, PERSISTENT UNEXPLAINED (INTERMITTENT OR CONSTANT, > 1 MONTH)'
      enc.fever_persistent_unexplained = "Yes"
    when 'PULMONARY TB'
      enc.pulmonary_tuberculosis = "Yes"
    when 'BACTERIAL INFECTIONS,SEVERE'
      enc.severe_bacterial_infection = "Yes"
    when 'BACTERIAL PNEUMONIA, SEVERE'
      enc.bacterial_pnuemonia = "Yes"
    when 'LYMPHOID INTERSTITIAL PNEUMONITIS'
      enc.symptomatic_lymphoid_interstitial_pnuemonitis = "Yes"
    when 'HIV-ASSOCIATED CHRONIC LUNG DISEASE'
      enc.chronic_hiv_assoc_lung_disease = "Yes"
    when 'ANAEMIA'
      enc.aneamia = "Yes"
    when 'Anemia 1-2 (Hb 7-9.4)'
      enc.anaemia = "Yes"
    when 'Anemia 3 (Hb 6.5-6.9)'
      enc.anaemia = "Yes"
    when 'Anemia 4 (Hb <6.5)'
      enc.anaemia = "Yes"
    when 'UNEXPLAINED ANAEMIA/NEUTROPENIA/THROMBOCYTOPENIA'
      enc.neutropaenia = "Yes"
    when 'THROMBOCYTOPAENIA, CHRONIC < 50,000 /MM(CUBED)'
      enc.thrombocytopaenia_chronic = "Yes"
    when 'DIARRHOEA UNEXPLAINED'
      enc.diarhoea = "Yes"
    when 'ORAL CANDIDIASIS'
      enc.oral_candidiasis = "Yes"
    when 'ACUTE NECROTIZING ULCERATIVE GINGIVITIS OR PERIODONTITIS'
      enc.acute_necrotizing_ulcerative_gingivitis = "Yes"
    when 'LYMPH NODE TB'
      enc.lymph_node_tuberculosis = "Yes"
    when 'TOXOPLASMOSIS OF THE BRAIN'
      enc.toxoplasmosis_of_brain = "Yes"
    when 'CRYPTOCOCCAL MENINGITIS'
      enc.cryptococcal_meningitis = "Yes"
    when 'PROGRESSIVE MULTIFOCAL LEUKOENCEPHALOPATHY'
      enc.progressive_multifocal_leukoencephalopathy = "Yes"
    when 'MYCOSIS DISSEMINATED'
      enc.disseminated_mycosis = "Yes"
    when 'CANDIDIASIS OF OESOPHAGUS/TRACHEA/BRONCHI/LUNGS'
      enc.candidiasis_of_oesophagus = "Yes"
    when 'EXTRAPULMONARY TB'
      enc.extrapulmonary_tuberculosis = "Yes"
    when 'LYMPHOMA'
      enc.cerebral_non_hodgkin_lymphoma = "Yes"
    when 'KAPOSI SARCOMA'
      enc.kaposis = "Yes"
    when 'ENCEPHALOPATHY BY HIV'
      enc.hiv_encephalopathy = "Yes"
    when 'PNEUMOCYSTIS PNEUMONIA'
      enc.pnuemocystis_pnuemonia = "Yes"
    when 'NON-TB MYCOBACTERIA INFECTION'
      enc.disseminated_non_tuberculosis_mycobactierial_infection = "Yes"
    when 'CRYPTOSPORIDIOSIS'
      enc.cryptosporidiosis = "Yes"
    when 'ISOSPORIASIS'
      enc.isosporiasis = "Yes"
    when 'HIV-ASSOCIATED NEPHROPATHY'
      enc.symptomatic_hiv_asscoiated_nephropathy = "Yes"
    when 'HERPES SIMPLEX INFECTION'
      enc.chronic_herpes_simplex_infection = "Yes"
    when 'CYTOMEGALOVIRUS INFECTION'
      enc.cytomegalovirus_infection = "Yes"
    when 'TOXOPLASMOSIS OF THE BRAIN (FROM AGE 1 MONTH)'
      enc.toxoplasomis_of_the_brain_1month = "Yes"
    when 'RECTO-VAGINAL FISTULA, HIV-ASSOCIATED'
      enc.recto_vaginal_fitsula = "Yes"
    when 'WASTING SYNDROME BY HIV/STUNTING/SEVERE MALNUTRITION'
      enc.hiv_wasting_syndrome = "Yes"

  end
end

def self.drug_induced_symptom(enc, intolerance)

  unless intolerance.blank?
    drug_cozed_symp =  $mysql_conn.query("SELECT FdsLookup FROM tbreference WHERE FdxReference = #{intolerance} LIMIT 1").fetch_row

    if ((drug_cozed_symp == "Mild Lipodystrophy") || (drug_cozed_symp == 'Severe Lipodystrophy'))
      enc.drug_induced_lipodystrophy = 'Yes'

    elsif ((drug_cozed_symp == 'Skin Eruption 1/2') || (drug_cozed_symp == 'Skin Eruption 3/4'))
      enc.drug_induced_skin_rash = 'Yes'

    elsif ((drug_cozed_symp == 'Diarrhea 1/2') || (drug_cozed_symp == 'Diarrhea 3') || (drug_cozed_symp == 'Diarrhea 4'))
      enc.drug_induced_diarrhoea = 'Yes'

    elsif (drug_cozed_symp == 'Jaundice')
      enc.drug_induced_jaundice = 'Yes'

    elsif ((drug_cozed_symp == 'Neuropathy 1-2') ||(drug_cozed_symp == 'Neuropathy 3') || (drug_cozed_symp == 'Neuropathy 4') )
      enc.drug_induced_peripheral_neuropathy = 'Yes'

    elsif ((drug_cozed_symp == 'Anemia 1-2 (Hb 7-9.4)')|| (drug_cozed_symp == 'Anemia 3 (Hb 6.5-6.9)') || (drug_cozed_symp == 'Anemia 4 (Hb <6.5)'))
      enc.drug_induced_anaemia = 'Yes'
    elsif (drug_cozed_symp == 'Lactic acidosis')
      enc.drug_induced_lactic_acidosis = 'Yes'
    else
      enc.drug_induced_other_symptom = 'Yes'
    end
  end

end



def pre_art_patient(patient_id, visit_day)

  received_before = $mysql_conn.query("SELECT * FROM tbpatientdrug WHERE FdxReferenceDrug NOT IN (56,148, 57, 58, 211) AND
                                        FdxReferencePatient = #{patient_id} AND FddBeginning < '#{visit_day}'")

  if received_before.num_rows > 0
    return false
  else
    receiving = $mysql_conn.query("SELECT * FROM tbfollowup AS e INNER JOIN tbfollowupdrug AS f ON
                                    e.FdxReference = f.FdxReferenceFollowUp WHERE e.FddVisit < '#{visit_day}'
                                    AND e.FdxReferencePatient = #{patient_id} AND f.FdxReferenceDrug NOT IN (56, 148, 57,58, 211)")
    if receiving.num_rows > 0
      return false
    else
      return true
    end

  end

end

def check_if_patient_has_tb(patientid, visit_date, tb_research)

  check = $mysql_conn.query("SELECT * FROM tbfollowuptb WHERE FdxReferencePatient = #{patientid} AND DATE('#{visit_date}')
                            BETWEEN DATE('FddTreatmentFrom') AND DATE('FddTreatmentTo')")

  if  check.num_rows > 0
      return "Confirmed TB on treatment"
  else
     if tb_research == 99
        return "Unknown"
     else
        return "TB suspected"
     end

  end

end

def get_brought(amount_dispensed, adherence)

  return amount_dispensed - (amount_dispensed *(adherence/100))

end

def get_dob(patient)

  if patient[11].blank?
     return get_dob_esitmated(patient[12],  patient[18])
  else
    return patient[11]
  end

end

def amount_dispensed(dose,duration)

  return dose * duration rescue duration

end

def create_patient_outcome(patientid, state, outcome_date)

  visit_id =  self.check_for_visit_date(patientid,outcome_date)


  pat_outcome = PatientOutcome.new()

  pat_outcome.visit_encounter_id = visit_id
  pat_outcome.outcome_id = $outcome_id
  pat_outcome.patient_id = patientid
  pat_outcome.outcome_state = state
  pat_outcome.outcome_date = outcome_date
  pat_outcome.save!
  $outcome_id += 1


end

def reason_for_starting_arv(patient, encounter, lymph_count)

  reason_for_eligibility = "Unknown"
  patient_age = encounter.encounter_datetime.to_date.year.to_i - get_dob(patient).to_date.year.to_i
  patient_adult = patient_age > 14 ? "ADULT" : "PEDS"
  age_in_months = patient_age * 12

  low_cd4_count_350 = false
  cd4_count_less_than_750 = false
  low_cd4_count_250 = false
  low_lymphocyte_count = false

  unless encounter.cd4_count.blank?
    if encounter.cd4_count <= 250 and (encounter.date_of_cd4_count < '2011-07-01'.to_date)
      low_cd4_count_250 = true
    elsif encounter.cd4_count <= 350 and (encounter.date_of_cd4_count >= '2011-07-01'.to_date)
      low_cd4_count_350 = true
    elsif encounter.cd4_count <= 750
      cd4_count_less_than_750 = true
    end

  end



  if encounter.who_stage == "WHO stage 3" || encounter.who_stage == "WHO stage 4"

     return "#{encounter.who_stage} #{patient_adult}"

  elsif low_cd4_count_350 and encounter.encounter_datetime  >= '2011-07-01'.to_date

    return "CD4 count < 350"

  elsif low_cd4_count_250

    return "CD4 count < 250"

  elsif low_lymphocyte_count and encounter.who_stage == "WHO stage 2"

    return "Lymphocyte count below threshold with WHO stage 2"

  elsif patient_adult == "PEDS"

      if age_in_months >= 12 and age_in_months < 24
        return "Child HIV positive"
      elsif (age_in_months >= 24 and age_in_months < 56) and cd4_count_less_than_750
        return "CD4 count < 750"
      else
        return "Unknown"
      end

   else

     return "Unknown"

  end



end

def durations(days)

  if days.between?(5,9)
    return "1 Week"
  elsif days.between?(10,17)
    return "2 weeks"
  elsif days.between?(18,24)
    return "3 weeks"
  elsif days.between?(28,45)
    return "1 month"
  elsif days.between?(46,75)
    return "2 months"
  elsif days.between?(76,105)
    return "3 months"
  else
    return nil
  end


end

def fix

  new_patient_id = PatientRecord.maximum("patient_id") + 1

  PatientRecord.update_all({:patient_id => new_patient_id}, {:patient_id => 1} )
  VisitEncounter.update_all({:patient_id => new_patient_id}, {:patient_id => 1} )
  VitalsEncounter.update_all({:patient_id => new_patient_id}, {:patient_id => 1} )
  GiveDrugsEncounter.update_all({:patient_id => new_patient_id}, {:patient_id => 1} )
  FirstVisitEncounter.update_all({:patient_id => new_patient_id}, {:patient_id => 1} )
  HivReceptionEncounter.update_all({:patient_id => new_patient_id}, {:patient_id => 1} )
  HivStagingEncounter.update_all({:patient_id => new_patient_id}, {:patient_id => 1} )
  ArtVisitEncounter.update_all({:patient_id => new_patient_id}, {:patient_id => 1} )
  PreArtVisitEncounter.update_all({:patient_id => new_patient_id}, {:patient_id => 1} )
  PatientOutcome.update_all({:patient_id => new_patient_id}, {:patient_id => 1} )


end



start
