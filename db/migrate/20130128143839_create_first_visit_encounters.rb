class CreateFirstVisitEncounters < ActiveRecord::Migration
  def self.up
ActiveRecord::Base.connection.execute <<EOF
DROP table if exists `first_visit_encounters`;
EOF

ActiveRecord::Base.connection.execute <<EOF
 CREATE table `first_visit_encounters`(
 	`id` int not null auto_increment primary key,
	`visit_encounter_id` int not null, 
	`patient_id` int not null,
	`agrees_to_follow_up` varchar(40) not null,
	`date_of_hiv_pos_test` date,
	`date_of_hiv_pos_test_estimated` date,
	`location_of_hiv_pos_test` varchar(255) not null,
	`ever_registered_at_art` varchar(25),
	`ever_received_arv` varchar(25),
	`last_arv_regimen` varchar(255),  
	`date_last_arv_taken` date,
	`date_last_arv_taken_estimated` date,
	`voided` tinyint(1) NOT NULL default 0,
	`void_reason` varchar(255),
	`date_voided` date,
	`voided_by` int (11),
	`date_created` date not null,
	`creator` int
 );
EOF
  end

  def self.down
    drop_table :first_visit_encounters
  end
end
