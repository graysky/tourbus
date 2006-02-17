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

  # Format time like the DB likes it
  def self.format_time(time)
    return time.strftime("%Y-%m-%d %H:%M:%S")
  end

  # Convenience to get the time now
  def self.now
    return format_time(Time.now)
  end

  # The number of fans
  def self.num_bands
    200
  end
  
  # The number of fans
  def self.num_fans
    500
  end
  
  # The number of venues
  def self.num_venues
    200
  end
  
  # Number of total relationships for fans of bands
  def self.num_bands_fans
    1000
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
    
    # Hardcoded
    num_zips = 43187
    
    return ZipCode.find_by_id( rand(num_zips) + 1 )
  end
  
  # Get a random Band (assumes they already exist)
  def self.rand_band
    return Band.find( rand(num_bands) + 1 )
  end
  
  # Get a random Fan (assumes they already exist)
  def self.rand_fan
    return Fan.find( rand(num_fans) + 1 )
  end
  
end