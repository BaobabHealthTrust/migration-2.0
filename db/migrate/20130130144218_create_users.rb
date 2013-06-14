class CreateUsers < ActiveRecord::Migration

def self.up
ActiveRecord::Base.connection.execute <<EOF
	drop table if exists `users`
EOF

ActiveRecord::Base.connection.execute <<EOF
create table `users`(
`id` int not null auto_increment primary key,
`user_id` int not null,
`username` varchar(255),
`first_name` varchar(255),
`middle_name` varchar(255),
`last_name` varchar(255),
`password` varchar(255),
`salt` varchar(255),
`user_role1` varchar(255),
`user_role2` varchar(255),
`user_role3` varchar(255),
`user_role4` varchar(255),
`user_role5` varchar(255),
`user_role6` varchar(255),
`user_role7` varchar(255),
`user_role8` varchar(255),
`user_role9` varchar(255),
`user_role10` varchar(255),
`date_created` date not null,
`voided` tinyint(1) not null default 0,
`void_reason` varchar(255),
`date_voided` date ,
`voided_by` int,
`creator` int not null default 1

);
EOF
end

  def self.down
    drop_table :users
  end
end
