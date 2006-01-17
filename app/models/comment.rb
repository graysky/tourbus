# Class to represent a comment
# TODO Consider adding:
# - rating
# - "keep user notified" about other comments
# - notify bands on new comments?
class Comment < ActiveRecord::Base
  # All the types that it could apply to.
  belongs_to :show
  belongs_to :band
  belongs_to :venue
  belongs_to :photo
  belongs_to :fan
  
  # Who create the comment
  belongs_to :created_by_band, :class_name => "Band", :foreign_key => "created_by_band_id"
  belongs_to :created_by_fan, :class_name => "Fan", :foreign_key => "created_by_fan_id"

  # They must have put in an actual message
  validates_presence_of :body, :message => "Cannot post empty comments"
  
  # Make sure that either a fan or band is associated with the comment.
  def validate
    if self.created_by_fan.nil? && self.created_by_band.nil?
      errors.add_to_base("You must be logged in to post comments")
    end
  end

  # Objects that can be commented on
  SHOW_COMMENT = 0
  BAND_COMMENT = 1
  FAN_COMMENT = 2  
  VENUE_COMMENT = 3
  PHOTO_COMMENT = 4
  
  # Getter for type
  def self.Show
    SHOW_COMMENT
  end
  
  def self.Band
    BAND_COMMENT
  end
  
  def self.Fan
    FAN_COMMENT
  end
  
  def self.Venue
    VENUE_COMMENT
  end
  
  def self.Photo
    PHOTO_COMMENT
  end
 
  # Get the name of the person who created the comment
  def created_by_name
    creator.name
  end 

  # The creator of the comment   
  def creator
    self.created_by_fan or self.created_by_band
  end


end
