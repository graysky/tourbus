class TurkHitType < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_presence_of :price
  validates_presence_of :title
  validates_presence_of :description
end