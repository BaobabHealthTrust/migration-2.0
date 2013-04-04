
def validate

	$missing_weights = 0
	$missing_heights = 0
	$empty_records_num = 0
	$empty_records = []
	$missing_height = []
	$missing_weight = []
	
	vitals = VitalsEncounter.find_by_sql("Select * from vitals_encounters")

	vitals.each do |vital|

		if vital.height.blank?

			$missing_heights +=1
			$missing_height << "Visit ID: #{vital.id}, Visit Encounter ID: #{vital.visit_encounter_id}, Patient ID: #{vital.patient_id}"
	
		end
		
		if vital.weight.blank?
		
			$missing_weights +=1
			$missing_weight << "Visit ID: #{vital.id}, Visit Encounter ID: #{vital.visit_encounter_id}, Patient ID: #{vital.patient_id}"
			
		end
		
	end

	$empty_records = $missing_height & $missing_weight 
	$empty_records_num = 	$empty_records.length
	write()	
end

def write

	vitals_file = File.open("./vitals_validation_report-#{Time.now.strftime("%Y-%m-%d-%H%M%S")}.txt", "w")
	vitals_file << "Total Records with missing Height: #{$missing_heights.to_s}\n Total Records with missing Weight: #{$missing_weights.to_s}\n Total Records with missing Height and Weight: #{$empty_records_num.to_s}\n\n Records with missing hieghts\n\n"
	
	$missing_height.each do |hieght|
		vitals_file << "#{hieght}\n"
	end
	vitals_file << "\nRecords with missing weights \n\n"
	
	$missing_weight.each do |wieght|
		vitals_file << "#{wieght}\n"
	end
	
	vitals_file << "\nRecords with missing weight and height \n\n"
	$empty_records.each do |empty|
		vitals_file << "#{empty}\n"
	end

end

validate 
