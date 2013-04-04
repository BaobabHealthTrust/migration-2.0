
def validate

	$incompletes = 0
	$incomplete_details = []
	
	encounters = GiveDrugsEncounter.find_by_sql("Select * from give_drugs_encounters")
	
	encounters.each do |enc|
	
		if (enc.pres_drug_name1.blank? && enc.pres_drug_name2.blank? && enc.pres_drug_name3.blank? &&enc.pres_drug_name4.blank? &&enc.pres_drug_name5.blank?) && (!enc.dispensed_drug_name1.blank? || !enc.dispensed_drug_name2.blank? || !enc.dispensed_drug_name3.blank? || !enc.dispensed_drug_name4.blank? || !enc.dispensed_drug_name5.blank?)
			
			$incomplete_details << ["Visit ID: #{enc.id}, Visit Encounter ID: #{enc.visit_encounter_id}, Patient ID: #{enc.patient_id}", " Dispensation without prescription"]
			$incompletes +=1
		
		elsif(!enc.pres_drug_name1.blank? || !enc.pres_drug_name2.blank? || !enc.pres_drug_name3.blank? || !enc.pres_drug_name4.blank? || !enc.pres_drug_name5.blank?) && (enc.dispensed_drug_name1.blank? && enc.dispensed_drug_name2.blank? && enc.dispensed_drug_name3.blank? && enc.dispensed_drug_name4.blank? && enc.dispensed_drug_name5.blank?)

			$incomplete_details << ["Visit ID: #{enc.id}, Visit Encounter ID: #{enc.visit_encounter_id}, Patient ID: #{enc.patient_id}", " Prescription without dispensation"]
			$incompletes +=1
		else
			prescribed = [enc.pres_drug_name1,enc.pres_drug_name2,enc.pres_drug_name3,enc.pres_drug_name4,enc.pres_drug_name5] 
	
			dispensed=	[enc.dispensed_drug_name1, enc.dispensed_drug_name2,enc.dispensed_drug_name3, enc.dispensed_drug_name4, enc.dispensed_drug_name5]
		
			if prescribed - dispensed != []

				$incomplete_details << ["Visit ID: #{enc.id}, Visit Encounter ID: #{enc.visit_encounter_id}, Patient ID: #{enc.patient_id}", " Prescribed but not dispensed"]
				$incompletes +=1
			
			elsif dispensed - prescribed != []

				$incomplete_details << ["Visit ID: #{enc.id}, Visit Encounter ID: #{enc.visit_encounter_id}, Patient ID: #{enc.patient_id}", " Dispensed but not prescribed"]
				$incompletes +=1

			
			end	
		
		end
		
	end

	write()	
end

def write

	outfile = File.open("./give_drugs_validation_report-#{Time.now.strftime("%Y-%m-%d-%H%M%S")}.txt", "w")
	outfile << "Total Incomplete Records: #{$incompletes}\n\nRecords Lists\n"
	
	$incomplete_details.each do |rec|
		outfile << "#{rec}\n"
	end
	
end

validate 
