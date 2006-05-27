class BandRelation < ActiveRecord::Base
  belongs_to :band1, :class_name => 'Band', :foreign_key => 'band1_id'
  belongs_to :band2, :class_name => 'Band', :foreign_key => 'band2_id'
end