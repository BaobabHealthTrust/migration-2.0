
def validate

	$incompletes = 0
	$incomplete_details = []
	
	encounters = OutpatientDiagnosisEncounter.find_by_sql("Select * from outpatient_diagnosis_encounters")
	
	encounters.each do |enc|
	
		if enc.pri_diagnosis.blank? && enc.sec_diagnosis.blank? && enc.treatment.blank? && enc.refer_to_anotha_hosp.blank?
			$incomplete_details << ["Visit ID: #{enc.id}, Visit Encounter ID: #{enc.visit_encounter_id}, Patient ID: #{enc.patient_id}", "Empty record"]
			$incompletes +=1

		elsif enc.pri_diagnosis.blank? && enc.sec_diagnosis.blank? && !enc.treatment.blank?
			$incomplete_details << ["Visit ID: #{enc.id}, Visit Encounter ID: #{enc.visit_encounter_id}, Patient ID: #{enc.patient_id}", "Missing diagnosis for prescription"]
			$incompletes +=1
			
		elsif !enc.pri_diagnosis.blank? && !enc.sec_diagnosis.blank? && enc.treatment.blank?
			$incomplete_details << ["Visit ID: #{enc.id}, Visit Encounter ID: #{enc.visit_encounter_id}, Patient ID: #{enc.patient_id}", "Missing prescription for diagnosis"]
			$incompletes +=1
		
		end

	end

	write()	
end

def write

	outfile = File.open("./outpatient_diag_validation_report-#{Time.now.strftime("%Y-%m-%d-%H%M%S")}.txt", "w")
	outfile << "Total Incomplete Records: #{$incompletes}\n\nRecords Lists\n"
	
	$incomplete_details.each do |rec|
		outfile << "#{rec}\n"
	end
	
end

validate 
