# A tag that is applied to different objects in the system.
# There is only 1 tag for any name, even if it is applied to different
# objects. 
class Tag < ActiveRecord::Base

  # TODO Need error handling for dup tag names
  validates_presence_of :name
  validates_uniqueness_of :name,
                          :message => "Tag already exists"

  # Types of tags
  BAND_TYPE = 1
  VENUE_TYPE = 2
  FAN_TYPE = 3
  PHOTO_TYPE = 4
  SHOW_TYPE = 5
  
  # Getter for type
  def self.Band
    BAND_TYPE
  end
  
  def self.Venue
    VENUE_TYPE
  end
  
  def self.Fan
    FAN_TYPE
  end
  
  def self.Photo
    PHOTO_TYPE
  end
  
  def self.Show
    SHOW_TYPE
  end
  
end
