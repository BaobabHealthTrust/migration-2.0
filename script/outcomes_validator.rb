
def validate

	$incompletes = 0
	$incomplete_details = []
	
	encounters = OutcomeEncounter.find_by_sql("Select * from outcome_encounters")
	
	encounters.each do |enc|
	
		if enc.state.blank?
			
			$incomplete_details << ["Visit ID: #{enc.id}, Visit Encounter ID: #{enc.visit_encounter_id}, Patient ID: #{enc.patient_id} ", " Missing updated outcome "]
			$incompletes +=1
		
		elsif enc.state.upcase == 'Transfer Out(With Transfer Note)' && enc.transferred_out_location.blank?
		
			$incomplete_details << ["Visit ID: #{enc.id}, Visit Encounter ID: #{enc.visit_encounter_id}, Patient ID: #{enc.patient_id} ", " Missing Transfer Out Location "]
			$incompletes +=1
		
		elsif enc.outcome_date.blank?
		
			$incomplete_details << ["Visit ID: #{enc.id}, Visit Encounter ID: #{enc.visit_encounter_id}, Patient ID: #{enc.patient_id} ", " Missing updated outcome date "]
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
