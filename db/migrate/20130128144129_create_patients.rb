class CreatePatients < ActiveRecord::Migration

def self.up
ActiveRecord::Base.connection.execute <<EOF
drop table if exists `patients`	;
EOF

ActiveRecord::Base.connection.execute <<EOF
	create table `patients`(
`id` int not null auto_increment primary key,
`given_name` varchar(255) not null,
`middle_name` varchar(255),
`family_name` varchar(255),
`gender` varchar(25) not null,
`DOB` date,
`DOB_estimated` date,
`TA` varchar(255),
`current_address` varchar(255),
`landmark` varchar(255),
`cellphone_number` varchar(255),
`home_phone_number` varchar(255),
`office_phone_number` varchar(255),
`occupation` varchar(255),
`nat_id` varchar(255),
`arv_number` varchar(255),
`pre_art_number` varchar(255),
`tb_number` varchar(255),
`legacy_id` varchar(255),
`legacy_id2` varchar(255),
`legacy_id3` varchar(255),
`new_nat_id` varchar(255),
`prev_art_number` varchar(255),
`filing_number` varchar(255),
`archived_filing_number` varchar(255),
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
    drop_table :patients
  end
end
