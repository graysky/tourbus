class Show < ActiveRecord::Base
  belongs_to :band
  belongs_to :venue
  belongs_to :tour
 
  validates_presence_of :date
end
