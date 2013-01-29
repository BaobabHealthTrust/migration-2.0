class Drug < ActiveRecord::Base
	set_table_name :drug
	set_primary_key :drug_id
	has_many :obs, :foreign_key => :value_drug
  has_many :drug_orders
  belongs_to :concept, :foreign_key => :concept_id
  belongs_to :user, :foreign_key => :user_id

	
end
