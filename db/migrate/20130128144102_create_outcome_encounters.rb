class CreateOutcomeEncounters < ActiveRecord::Migration
  def self.up
ActiveRecord::Base.connection.execute <<EOF
drop table if exists `outcome_encounters`
EOF

ActiveRecord::Base.connection.execute <<EOF
create table `outcome_encounters`(
`id` int not null auto_increment primary key,
`visit_date`int not null,
`patient_id` int not null,
`state` varchar(255),
`outcome_date` date not null,
`transferred_out_location` varchar(255),
`voided` int not null default 0,
`void_reason` varchar(255),
`date_voided` date,
`voided_by` int,
`date_created` date not null,
`creator` int not null

);

EOF

  end

  def self.down
    drop_table :outcome_encounters
  end
end
