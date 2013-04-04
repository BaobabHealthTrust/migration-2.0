
def validate

	$incompletes = 0
	$incomplete_details = []
	
	encounters = PreArtVisitEncounter.find_by_sql("Select * from pre_art_visit_encounters")
	
	encounters.each do |enc|
	
		if enc.tb_status.blank?
			$incomplete_details << ["Visit ID: #{enc.id}, Visit Encounter ID: #{enc.visit_encounter_id}, Patient ID: #{enc.patient_id}", "Missing TB Status"]
			$incompletes +=1
		end
		
		if enc.prescribe_cpt.blank?
			$incomplete_details << ["Visit ID: #{enc.id}, Visit Encounter ID: #{enc.visit_encounter_id}, Patient ID: #{enc.patient_id}", "Missing Prescribe CPT Answer"]
			$incompletes +=1
		end
	end

	write()	
end

def write

	outfile = File.open("./pre-art_validation_report-#{Time.now.strftime("%Y-%m-%d-%H%M%S")}.txt", "w")
	outfile << "Total Incomplete Records: #{$incompletes}\n\nRecords Lists\n"
	
	$incomplete_details.each do |rec|
		outfile << "#{rec}\n"
	end
	
end

validate 
