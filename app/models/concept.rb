class Concept < ActiveRecord::Base
  set_table_name "concept"
  has_many :observations, :foreign_key => :concept_id
end
