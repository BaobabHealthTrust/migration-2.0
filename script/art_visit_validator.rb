
def validate

	$incompletes = 0
	$incomplete_details = []
	
	encounters = ArtVisitEncounter.find_by_sql("Select * from art_visit_encounters")
	
	encounters.each do |enc|
	
		if enc.state.blank?
			
			$incomplete_details << ["Visit ID: #{enc.id}, Visit Encounter ID: #{enc.visit_encounter_id}, Patient ID: #{enc.patient_id} ", " Missing updated outcome "]
			$incompletes +=1
		
		elsif enc.state.upcase == 'Transfer Out(With Transfer Note)' && enc.transferred_out_location.blank?
		
			$incomplete_details << ["Visit ID: #{enc.id}, Visit Encounter ID: #{enc.visit_encounter_id}, Patient ID: #{enc.patient_id} ", " Missing Transfer Out Location "]
			$incompletes +=1
		
		elsif enc.tb_status.blank?
		
			$incomplete_details << ["Visit ID: #{enc.id}, Visit Encounter ID: #{enc.visit_encounter_id}, Patient ID: #{enc.patient_id} ", " Missing TB status"]
			$incompletes +=1

		elsif enc.prescribe_arv.blank?
		
			$incomplete_details << ["Visit ID: #{enc.id}, Visit Encounter ID: #{enc.visit_encounter_id}, Patient ID: #{enc.patient_id} ", " Missing prescribe arv answer "]
			$incompletes +=1
			
		elsif enc.prescribe_arv.upcase == "YES"
		
			if enc.arv_regimen.blank?
				$incomplete_details << ["Visit ID: #{enc.id}, Visit Encounter ID: #{enc.visit_encounter_id}, Patient ID: #{enc.patient_id} ", " Missing prescribed arv regimen "]
				$incompletes +=1

			end

		elsif enc.prescribe_cpt.blank?
		
			$incomplete_details << ["Visit ID: #{enc.id}, Visit Encounter ID: #{enc.visit_encounter_id}, Patient ID: #{enc.patient_id} ", " Missing prescribe art answer "]
			$incompletes +=1

		elsif enc.continue_treatment_at_clinic.blank?
		
			$incomplete_details << ["Visit ID: #{enc.id}, Visit Encounter ID: #{enc.visit_encounter_id}, Patient ID: #{enc.patient_id} ", " No response to continue treatment at facility "]
			$incompletes +=1
		
		end
		

	end

	write()	
end

def write

	outfile = File.open("./outcome_validation_report-#{Time.now.strftime("%Y-%m-%d-%H%M%S")}.txt", "w")
	outfile << "Total Incomplete Records: #{$incompletes}\n\nRecords Lists\n"
	
	$incomplete_details.each do |rec|
		outfile << "#{rec}\n"
	end
	
end

validate 
