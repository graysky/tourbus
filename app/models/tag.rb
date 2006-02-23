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
  
  # Converts from tag type to string representing tag type
  # Useful for tag link to search
  def self.get_type_name(tag_type)
    
    # Convert from string to fixnum if needed
    if tag_type.kind_of?(String)
      tag_type = tag_type.to_i
    end
    
    case tag_type
      
    when BAND_TYPE
      return "band"
    when VENUE_TYPE
      return "venue"
    when SHOW_TYPE
      return "show"
    when PHOTO_TYPE
      return "photo"
    when FAN_TYPE
      return "fan"
    end

    return "unknown"    
  end
  
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
