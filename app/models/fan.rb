# Schema as of Thu Mar 02 20:14:39 Eastern Standard Time 2006 (schema version 17)
#
#  id                  :integer(11)   not null
#  name                :string(100)   default(), not null
#  real_name           :string(100)   default(), not null
#  contact_email       :string(100)   default(), not null
#  zipcode             :string(5)     
#  city                :string(100)   default()
#  state               :string(2)     default()
#  bio                 :text          
#  salt                :string(40)    
#  website             :string(100)   default()
#  salted_password     :string(40)    default(), not null
#  logo                :string(100)   default(), not null
#  confirmed           :boolean(1)    not null
#  confirmation_code   :string(50)    default()
#  created_on          :datetime      
#  page_views          :integer(10)   default(0)
#  last_favorites_email:datetime      
#  default_radius      :integer(6)    default(35)
#  wants_favorites_emai:boolean(1)    default(true), not null
#  admin               :boolean(1)    not null
#  security_token      :string(40)    
#  token_expiry        :datetime      
#  show_reminder_first :integer(10)   default(4320)
#  show_reminder_second:integer(10)   default(360)
#  wants_email_reminder:boolean(1)    default(true)
#  wants_mobile_reminde:boolean(1)    
#  last_show_reminder  :datetime      
#  uuid                :string(40)    
#  last_updated        :datetime      
#  superuser           :boolean(1)    
#  mobile_number       :string(20)    
#  carrier_type        :integer(10)   default(-1)
#  show_watching_remind:integer(10)   default(4320)
#  latitude            :string(30)    
#  longitude           :string(30)    
#

require_dependency "password_protected"
require_dependency "searchable"
require_dependency "address"
require_dependency "mobile_address"

# Model that describes a music fan
class Fan < ActiveRecord::Base
  include ActiveRecord::Acts::PasswordProtected
  include FerretMixin::Acts::Searchable
  include Address::ActsAsLocation
  include MobileAddress
  include UpcomingShows
  
  acts_as_password_protected
  file_column :logo, :magick => { :geometry => "200x300>" }
  has_many :photos, :class_name => "Photo", :foreign_key => "created_by_fan_id", :order => "created_on DESC"
  has_one :upload_addr
  has_and_belongs_to_many :bands
  has_and_belongs_to_many :shows, :order => "date ASC"
  has_many :comments, :order => "created_on ASC"
  has_many :wish_list_bands
 
  validates_uniqueness_of :uuid # just in case
  
  # TODO No spaces in name
  validates_presence_of :name, :contact_email
  validates_uniqueness_of :name, 
                          :message => "Sorry, that name has already been taken."
  
  validates_uniqueness_of :contact_email, 
                          :message => "Sorry, someone has already signed up with that email address.",
                          :if => :validate_unique_email?
  
                          
  validates_presence_of :password, :if => :validate_password?
  validates_length_of :password, :minimum => 4, :if => :validate_password?
  validates_confirmation_of :password, :if => :validate_password?
  
  def self.admin_user
    self.find_by_name('admin')
  end
  
  # Return if the band is among the fan's favorites
  def favorite?(band)
    self.bands.detect { |fav| fav == band }
  end
  
  def attend_show(show)
    self.shows.push_with_attributes(show, { :attending => true, :watching => false })
    show.num_attendees += 1
  end
  
  def add_wish_list_bands(*bands)
    bands.each { |band| self.wish_list_bands << WishListBand.new(:name => band) }
  end
  
  def find_wish_list_band(name)
    self.wish_list_bands.find_by_name(name) || self.wish_list_bands.find_by_short_name(Band.name_to_id(name))
  end
  
  def stop_attending_show(show)
    if self.attending?(show)
      self.shows.delete(show)
      show.num_attendees -= 1
    end
  end
  
  def watch_show(show)
    self.shows.push_with_attributes(show, { :attending => false, :watching => true })
    show.num_watchers += 1
  end
  
  def stop_watching_show(show)
    if self.watching?(show)
      self.shows.delete(show)
      show.num_watchers -= 1
    end
  end
  
  def watching_shows
    self.shows.find(:all, :conditions => "watching = 1")
  end
  
  def attending_shows
    self.shows.find(:all, :conditions => "attending = 1")
  end
  
  # Return if the show is one the fan is attending
  def attending?(show)
    self.attending_shows.detect { |x| x == show  }
  end
  
  # Return if the show is one the fan is watching
  def watching?(show)
    self.watching_shows.detect { |x| x == show  }
  end
                          
  # Creates and sets the confirmation code. DOES NOT save the record.
  # Requires that that object already be populated with required fields
  def create_confirmation_code
    self.confirmation_code = Hash.hashed(self.name + rand.to_s)
    return self.confirmation_code
  end
  
  # The upload email address, fully qualified like "down42tree@tourb.us"
  def upload_email_addr()
    return upload_addr.address + "@" + UploadAddr.Domain
  end
  
  def location
    return self.city + ", " + self.state unless self.city.nil? or self.city == ""
    return ""
  end
  
  # Returns the band if it was authenticated.
  # May return an unconfirmed band, the caller must check.
  def self.authenticate(login, password)
    fan = find_by_name(login)
    return nil if fan.nil?
    return find(:first, 
                :conditions => ["confirmed = 1 and name = ? and salted_password = ?", login, Fan.salted_password(fan.salt, Hash.hashed(password))])
  end
  
  # Get the mobile email address for this fan
  def mobile_email

    return MobileAddress::get_mobile_email(mobile_number, carrier_type)
  end  
  
  # Returns an array of reminder options in minutes
  def self.reminder_options
    
    ops = [
            ["---", 0], ["1 hour", 60], 
            ["2 hours", 120], ["3 hours", 180], ["6 hours", 360], ["12 hours", 720],
            ["1 day", 1440], ["2 days", 2880], ["3 days", 4320],
            ["7 days", 10080], ["10 days", 14400], ["14 days", 20160]
          ]
  end
  
  # Returns an array of reminder options in minutes for watching shows
  def self.watching_reminder_options
    ops = [
            ["Never", 0],
            ["1 day", 1440], ["2 days", 2880], ["3 days", 4320],
            ["7 days", 10080], ["10 days", 14400], ["14 days", 20160]
          ]
  end

end
