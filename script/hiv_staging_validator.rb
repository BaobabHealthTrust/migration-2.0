
def validate

	$incompletes = 0
	$incomplete_details = []
	
	encounters = HivStagingEncounter.find_by_sql("Select * from hiv_staging_encounters")
	
	encounters.each do |enc|
	
		if enc.cd4_count_available.blank?
			$incomplete_details << ["Visit ID: #{enc.id}, Visit Encounter ID: #{enc.visit_encounter_id}, Patient ID: #{enc.patient_id}", "Missing CD4 count available answer"]
			$incompletes +=1
		elsif enc.cd4_count_available.upcase == "YES"
			if enc.cd4_count.blank?
				$incomplete_details << ["Visit ID: #{enc.id}, Visit Encounter ID: #{enc.visit_encounter_id}, Patient ID: #{enc.patient_id}", "Missing CD4 count"]
			$incompletes +=1
			end
		end

		if enc.reason_for_starting_art.blank?
			$incomplete_details << ["Visit ID: #{enc.id}, Visit Encounter ID: #{enc.visit_encounter_id}, Patient ID: #{enc.patient_id}", "Missing Reason for starting"]
			$incompletes +=1

		end

		if enc.who_stage.blank?
			$incomplete_details << ["Visit ID: #{enc.id}, Visit Encounter ID: #{enc.visit_encounter_id}, Patient ID: #{enc.patient_id}", "Missing WHO stage"]
			$incompletes +=1

		end

	end

	write()	
end

def write

	outfile = File.open("./hiv_staging_validation_report-#{Time.now.strftime("%Y-%m-%d-%H%M%S")}.txt", "w")
	outfile << "Total Incomplete Records: #{$incompletes}\n\nRecords Lists\n"
	
	$incomplete_details.each do |rec|
		outfile << "#{rec}\n"
	end
	
end

validate 
