# Class to help build up fixtures for testing
# TODO I tried to do this as a module but couldn't get it right?
class FixtureHelper

  # Words to make Band names out of
  BAND_WORDS = [ "Monkey", "Torture", "Death", "Metal", "Foo", "Crisis", "Endgame", "Blue", "Code",
  "Fire", "Balls", "Eyes", "Snow", "Ice", "Tree", "Buzz", "Star", "Ruby",
  ]

  # Words to make fan names out of 
  FAN_FIRST_NAMES = [ "Mike", "Gary", "Sam", "Kim", "Steven", "Bill", "Matt", "Jenny", "Billy", "David", "Karl"
  ]
   
  FAN_LAST_NAMES = [ "Elliot", "Smith", "Doe", "Blah", "Monkey", "Ugly", "Rock", "Green", "Gold",
  ]
  
  # Words to make Venue names from
  VENUE_FIRST_NAMES = [ "MidEast", "Axis", "Avalon", "Punk", "Downstairs", "Paradise", "Pete's"
  ]
  
  VENUE_LAST_NAMES = [ "Club", "Venue", "Lounge", "Bar", "Disco" ]

  # The list of tags
  TAGS = ["emo", "punk", "hardcore", "indie", "hip-hop", "pop", "indie rock", "folk", "hippie", "surf", "hillbilly", "boston", ]

  # Format time like the DB likes it
  def self.format_time(time)
    return time.strftime("%Y-%m-%d %H:%M:%S")
  end

  # Time for now
  def self.now
    return format_time(Time.now)
  end

  # Time for next week
  def self.next_week
    1.week.from_now.to_s(:db)
  end
  
  # Time for last week
  def self.last_week
    1.week.ago.to_s(:db)
  end
  
  # Time for some days from now
  def self.days_from_now(num)
    num.days.from_now.to_s(:db)
  end

  # Number of US zip codes
  def self.num_zips  
    # Hardcoded
    43187
  end

  # The number of fans
  def self.num_bands
    100
  end
  
  # The number of fans
  def self.num_fans
    200
  end
  
  # Number of venues
  def self.num_venues
    50
  end
  
  # Number of shows
  def self.num_shows
    100
  end
  
  # Number of bands playing shows
  def self.num_bands_shows
    200
  end
  
  # The number of tags
  def self.num_tags
    TAGS.size
  end
  
  # Number of tags to apply to bands
  def self.num_tags_bands
    200
  end
  
  # Number of total relationships for fans of bands
  def self.num_bands_fans
    500
  end

  # Generate a band name using the id to make it unique
  def self.gen_band_name(id)
    idx1 = rand(BAND_WORDS.length)
    idx2 = rand(BAND_WORDS.length)
    name = ""
    
    # Create 2 word band name
    name << "#{BAND_WORDS[idx1]} #{BAND_WORDS[idx2]}"
    
    return name
  end

  
  # Generate a fan name using the id to make it unique
  def self.gen_fan_name(id)
    return "Fan#{id}"
  end
  
  # Get the tag at the index
  def self.get_tag(idx)
    return TAGS[idx]
  end
  
  # Generate a venue name
  def self.gen_venue_name(id)
    idx1 = rand(VENUE_FIRST_NAMES.length)
    idx2 = rand(VENUE_LAST_NAMES.length)
    name = ""
    
    # Create 2 word venue name
    name << "#{VENUE_FIRST_NAMES[idx1]} #{VENUE_LAST_NAMES[idx2]}"
    
    return name
  end
  
  # Get a random ZipCode
  def self.rand_zip
    return ZipCode.find_by_id( rand(num_zips) + 1 )
  end
  
  # Get a random zipcode from around Boston
  def self.rand_boston_zip
    zips = []
    zips = zips + ZipCode.find(:all, :conditions => "city = 'Boston'")
    zips = zips + ZipCode.find(:all, :conditions => "city = 'Cambridge'")
    zips = zips + ZipCode.find(:all, :conditions => "city = 'Somerville'")
    zips = zips + ZipCode.find(:all, :conditions => "city = 'Brighton'")
    
    num = zips.size
    return zips[ rand(num) ]
  end
  
  # Get a random Band (assumes they already exist)
  # If show id is passed, use to make sure it is not already playing that show.
  def self.rand_band(show_id = 0)
    return Band.find( rand(num_bands) + 1 )
  end
  
  # Get a random Fan (assumes they already exist)
  def self.rand_fan
    return Fan.find( rand(num_fans) + 1 )
  end
  
  # Get a random Venue (assumes they already exist)
  def self.rand_venue
    return Venue.find( rand(num_venues) + 1 )
  end
  
  # Get a random Show (assumes they already exist)
  def self.rand_show
    return Show.find( rand(num_shows) + 1 )
  end
  
  # Get a random Tag (assumes they already exist)
  def self.rand_tag
    return Tag.find( rand(num_tags) + 1 )
  end
  
end