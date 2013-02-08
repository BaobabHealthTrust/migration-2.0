class Patient < ActiveRecord::Base
  set_table_name :patient                                                       
  set_primary_key :patient_id                                                    
	has_one :guardian

  def age_in_months(reference_date = Time.now)
    ((reference_date.to_time - self.birthdate.to_time)/1.month).floor rescue nil
  end


end
