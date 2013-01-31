class CreateGuardians < ActiveRecord::Migration
  def self.up
ActiveRecord::Base.connection.execute <<EOF
drop table if exists 'guardians';
EOF

ActiveReord::Base.connection.execute <<EOF
create table 'guardians'(
'id' int not null auto_increment,
'patient_id' int not null,
'name' varchar(255),
'relationship' varchar(255),
'family_name' varchar(255),
'gender' varchar(255),
'voided' tinyint(1) not null defualt 0,
'void_reason' varchar(255),
'date_voided' date ,
'voided_by' int,
'date_created' date not null,
'creator' int not null

);
EOF
  end

  def self.down
    drop_table :guardians
  end
end
