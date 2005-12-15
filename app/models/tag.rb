# A tag that is applied to different objects in the system.
# There is only 1 tag for any name, even if it is applied to different
# objects. 
class Tag < ActiveRecord::Base

  validates_presence_of :name
  validates_uniqueness_of :name

  # Types of tags
  GENRE_TYPE = 0
  INFLUENCE_TYPE = 1
  MISC_TYPE = 2
  VENUE_TYPE = 3
  FAN_TYPE = 4
  PHOTO_TYPE = 5
  SHOW_TYPE = 6
  
  # Getter for type
  def self.Genre
    GENRE_TYPE
  end
  
  def self.Influence
    INFLUENCE_TYPE
  end
  
  def self.Misc
    MISC_TYPE
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
  
  # Get a string name for the tag type
  def self.type_name(tag_type)
    case tag_type
      when GENRE_TYPE
        "Genre"
      when INFLUENCE_TYPE
        "Influence"
      when MISC_TYPE
        "Other"
      when VENUE_TYPE
        "Venue"
      when FAN_TYPE
        "Fan"
      when SHOW_TYPE
        "Show"
      when PHOTO_TYPE
        "Photo"
      else
        "Error"
    end
  end

end
