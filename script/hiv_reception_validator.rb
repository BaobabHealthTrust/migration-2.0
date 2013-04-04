
def validate

	$incompletes = 0
	$incomplete_details = []
	
	encounters = HivReceptionEncounter.find_by_sql("Select * from hiv_reception_encounters")
	
	encounters.each do |enc|
	
		if !enc.guardian_present.blank? && enc.guardian.blank?
			
			$incomplete_details << ["Visit ID: #{enc.id}, Visit Encounter ID: #{enc.visit_encounter_id}, Patient ID: #{enc.patient_id} ", " Missing Guardian ID"]
			$incompletes +=1
			
		end
	end

	write()	
end

def write

	outfile = File.open("./hiv-reception_validation_report-#{Time.now.strftime("%Y-%m-%d-%H%M%S")}.txt", "w")
	outfile << "Total Incomplete Records: #{$incompletes}\n\nRecords Lists\n"
	
	$incomplete_details.each do |rec|
		outfile << "#{rec}\n"
	end
	
end

validate 
