class CreatePatientHistoricalOutcome < ActiveRecord::Migration
  def self.up
ActiveRecord::Base.connection.execute <<EOF
drop table if exists `patient_historical_outcomes`
EOF

ActiveRecord::Base.connection.execute <<EOF
create table `patient_historical_outcomes`(
`id` int not null auto_increment primary key,
`visit_encounter_id` int not null,
`outcome_id` int not null,
`patient_id` int not null,
`state` varchar(255),
`outcome_date` date 

);

EOF

  end

  def self.down
    drop_table :patient_historical_outcomes
  end
end
