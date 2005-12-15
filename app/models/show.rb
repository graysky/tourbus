require "taggable"
require "tagging"

# A specific show that is being played a venue by a list of bands.
class Show < ActiveRecord::Base
  include Tagging
  has_and_belongs_to_many :bands
  belongs_to :venue
  belongs_to :tour
  has_many :photos, :order => "created_on DESC"
  has_many :comments, :order => "created_at ASC"
  acts_as_taggable :join_class_name => 'TagShow'
  validates_presence_of :date
  
  # Attributes for nicer date handling
  attr_accessor :formatted_date, :time_hour, :time_minute, :time_ampm
  
  # ActiveRecord callback:
  # Convert our formatted date attributes into the real date 
  def before_validation
    # Create a string that ParseDate can handle
    date_str = "#{@formatted_date} #{@time_hour}:#{@time_minute}#{@time_ampm}"
    components = ParseDate.parsedate(date_str)
    self.date = Time.local(*components)
  end
  
  def formatted_date
    return @formatted_date if self.date.nil?
    
    month = Date::MONTHNAMES[self.date.month] 
    "#{month} #{self.date.day}, #{self.date.year}"
  end
  
  def time_hour
    return @time_hour if self.date.nil?
    ampm = time_ampm
    if (ampm == "PM")
      return self.date.hour - 12
    elsif (self.date.hour == 0)
      return 12
    else
      return self.date.hour
    end  
  end
  
  def time_minute
    return @time_minute if self.date.nil?
    self.date.min
  end
  
  def time_ampm
    return @time_ampm if self.date.nil?
    if (self.date.hour > 12)
      return "PM"
    else
      return "AM"
    end
  end
  
  # Add Show tags
  def show_tag_names=(tags)
    add_tags(tags, Tag.Show)
  end

  # Get just the Show tags
  def show_tag_names
    get_tags(Tag.Show)
  end
  
end
