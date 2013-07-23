
def fix

  new_patient_id = PatientRecord.maximum("patient_id") + 1

  PatientRecord.update_all({:patient_id => new_patient_id}, {:patient_id => 1} )
  VisitEncounter.update_all({:patient_id => new_patient_id}, {:patient_id => 1} )
  VitalsEncounter.update_all({:patient_id => new_patient_id}, {:patient_id => 1} )
  GiveDrugsEncounter.update_all({:patient_id => new_patient_id}, {:patient_id => 1} )
  FirstVisitEncounter.update_all({:patient_id => new_patient_id}, {:patient_id => 1} )
  HivReceptionEncounter.update_all({:patient_id => new_patient_id}, {:patient_id => 1} )
  HivStagingEncounter.update_all({:patient_id => new_patient_id}, {:patient_id => 1} )
  ArtVisitEncounter.update_all({:patient_id => new_patient_id}, {:patient_id => 1} )
  PreArtVisitEncounter.update_all({:patient_id => new_patient_id}, {:patient_id => 1} )
  PatientOutcome.update_all({:patient_id => new_patient_id}, {:patient_id => 1} )


end

fix