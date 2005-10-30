# A tag that is applied to a band.
class Tag < ActiveRecord::Base
  has_and_belongs_to_many :bands

  validates_presence_of :name
  validates_uniqueness_of :name

end
