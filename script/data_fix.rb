def fix
	bad_data = PatientRecord.find_by_sql("select * from patients where given_name is null and family_name is null")
	
	bad_data.each do |patient|
		
		temp = PatientName.find(:first, :conditions => ["patient_id = ? ", patient.patient_id])
		
		patient.given_name = "#{temp.given_name}" rescue nil
		patient.family_name = "#{temp.family_name}" rescue nil
		patient.save(false)
		
	end
	puts "\nRecords affected #{bad_data.length}"
	#fix_ids
end


def fix_ids
		bad_data = PatientRecord.find_by_sql("select * from patients where nat_id is null and new_nat_id is null")
		
		bad_data.each do |patient|
		
			patient.nat_id = PatientIdentifiers.find(:first, :conditions => ["patient_id = ? and identifier_type = ?", patient.patient_id, 1]).identifier rescue nil
			
			patient.new_nat_id = PatientIdentifiers.find(:first, :conditions => ["patient_id = ? and identifier_type = ?", patient.patient_id, 25]).identifier rescue nil
		
		end
end
fix
