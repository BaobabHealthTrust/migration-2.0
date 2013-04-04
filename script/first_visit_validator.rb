
def validate

	$incompletes = 0
	$incomplete_details = []
	
	encounters = FirstVisitEncounter.find_by_sql("Select * from first_visit_encounters")
	
	encounters.each do |enc|
	
		if enc.date_of_hiv_pos_test.blank?
			$incomplete_details << ["Visit ID: #{enc.id}, Visit Encounter ID: #{enc.visit_encounter_id}, Patient ID: #{enc.patient_id}", " Missing Date of HIV positive test"]
			$incompletes +=1

		end
		
		if enc.ever_registered_at_art.blank?
			$incomplete_details << ["Visit ID: #{enc.id}, Visit Encounter ID: #{enc.visit_encounter_id}, Patient ID: #{enc.patient_id}", " Missing ANS to ever registered at art clinic"]
			$incompletes +=1
		end

		if enc.ever_received_arv.blank?
			$incomplete_details << ["Visit ID: #{enc.id}, Visit Encounter ID: #{enc.visit_encounter_id}, Patient ID: #{enc.patient_id}", " Missing ANS to ever received ART"]
			$incompletes +=1
			
		elsif enc.ever_received_arv.upcase == "YES"
			if enc.last_arv_regimen.blank?			
				$incomplete_details << ["Visit ID: #{enc.id}, Visit Encounter ID: #{enc.visit_encounter_id}, Patient ID: #{enc.patient_id}", " Missing last ARV regimen"]
				$incompletes +=1
			end 
			
			if enc.date_last_arv_taken.blank?
				$incomplete_details << ["Visit ID: #{enc.id}, Visit Encounter ID: #{enc.visit_encounter_id}, Patient ID: #{enc.patient_id}", " Missing last date ARV taken"]
				$incompletes +=1
			elsif enc.date_last_arv_taken.to_s.upcase == "UNKNOWN" && enc.taken_arvs_in_last_two_month.blank?
				$incomplete_details << ["Visit ID: #{enc.id}, Visit Encounter ID: #{enc.visit_encounter_id}, Patient ID: #{enc.patient_id}", " Missing estimated last date ARV taken"]
				$incompletes +=1				
			end
		end

	end

	write()	
end

def write

	outfile = File.open("./first_visit_validation_report-#{Time.now.strftime("%Y-%m-%d-%H%M%S")}.txt", "w")
	outfile << "Total Incomplete Records: #{$incompletes}\n\nRecords Lists\n"
	
	$incomplete_details.each do |rec|
		outfile << "#{rec}\n"
	end
	
end

validate 
