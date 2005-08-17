class Show < ActiveRecord::Base
  belongs_to :band
  
  validates_presence_of :venue, :zipcode, :date
end
