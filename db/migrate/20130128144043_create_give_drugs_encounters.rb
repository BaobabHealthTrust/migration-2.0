class CreateGiveDrugsEncounters < ActiveRecord::Migration
  def self.up

ActiveRecord::Base.connection.execute <<EOF
drop table if exists `give_drug_encounters`;
EOF

ActiveRecord::Base.connection.execute <<EOF
create table `give_drugs_encounters`(
`id` int not null auto_increment primary key,
`visit_encounter_id` int not null,
`patient_id` int not null,
`drug_name1` varchar(255),
`dispensed_quantity1` int,
`drug_name2` varchar(255),
`dispensed_quantity2` int,
`drug_name3` varchar(255),
`dispensed_quantity3` int,
`drug_name4` varchar(255),
`dispensed_quantity4` int,
`drug_name5` varchar(255),
`dispensed_quantity5` int,
`voided` tinyint(1) not null default 0,
`void_reason` varchar(255),
`date_voided` date ,
`voided_by` int,
`date_created` date not null,
`creator` int not null
);
EOF
  end

  def self.down
    drop_table :give_drugs_encounters
  end
end
