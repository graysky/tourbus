module Address
  STATE_ABBREVS = %w{ AK AL AR AZ CA CO CT DE FL GA HI IA ID IL IN KS KY LA MA MD ME
                 MI MN MO MS MT NC ND NE NH NJ NM NV NY OH OK OR PA RI SC SD TN
                 TX UT VT VA WA WI WV WY } unless const_defined?("STATE_ABBREVS")
                 
  STATES = {
    "alabama" => "AL", 
    "alaska" => "AK", 
    "arizona" => "AZ", 
    "arkansas" => "AR", 
    "california" => "CA", 
    "colorado" => "CO", 
    "connecticut" => "CT", 
    "delaware" => "DE", 
    "district of columbia" => "DC", 
    "florida" => "FL", 
    "georgia" => "GA", 
    "hawaii" => "HI", 
    "idaho" => "ID", 
    "illinois" => "IL", 
    "indiana" => "IN", 
    "iowa" => "IA", 
    "kansas" => "KS", 
    "kentucky" => "KY", 
    "louisiana" => "LA", 
    "maine" => "ME", 
    "maryland" => "MD", 
    "massachusetts" => "MA", 
    "michigan" => "MI", 
    "minnesota" => "MN", 
    "mississippi" => "MS", 
    "missouri" => "MO", 
    "montana" => "MT", 
    "nebraska" => "NE", 
    "nevada" => "NV", 
    "new hampshire" => "NH", 
    "new jersey" => "NJ", 
    "new mexico" => "NM", 
    "new york" => "NY", 
    "north carolina" => "NC", 
    "north dakota" => "ND", 
    "ohio" => "OH", 
    "oklahoma" => "OK", 
    "oregon" => "OR", 
    "pennsylvania" => "PA", 
    "rhode island" => "RI", 
    "south carolina" => "SC", 
    "south dakota" => "SD", 
    "tennessee" => "TN", 
    "texas" => "TX", 
    "utah" => "UT", 
    "vermont" => "VT", 
    "virginia" => "VA", 
    "washington" => "WA", 
    "west virginia" => "WV", 
    "wisconsin" => "WI", 
    "wyoming" => "WY"
  } unless const_defined?("STATES")
  
  def self.state_abbrev(name_or_abbrev)
    val = STATE_ABBREVS.find { |abbrev| abbrev == name_or_abbrev.upcase }
    return val if val
    
    STATES[name_or_abbrev.downcase]
  end
  
  # Parse a string that contains a city and state AND/OR zipcode
  # Returns a zipcode object
  # If no zip given, an arbitrary zip code is chosen from the city
  # FIXME Should be the center
  # Throws an exception if it cannot be recognized
  def self.parse_city_state_zip(str)
    return nil if str.nil? or str == ""
    
    city_words = []
    city = state = zip = nil
    
    tokens = str.split(/,/)
    if tokens.size == 1
      zip = tokens[0].strip
    else
      city = tokens[0].strip
      state = self.state_abbrev(tokens[1].strip)
    end
    
    raise "Invalid address: Missing city or zipcode" if city == "" and zip.nil?
    raise "Invalid address: Missing state" if state.nil? and zip.nil?
 
    # If we have a zip code look it up and use it. Otherwise, try to use the city and state
    begin
      if not zip.nil?
        zipcode = ZipCode.find_by_zip(zip)
        raise "Invalid address: Unknown zipcode: #{zip}" if zipcode.nil?
      else
        zipcode = ZipCode.find_by_city_and_state(city.capitalize, state.upcase)
        raise "Invalid address: Unknown city and state: #{city}, #{state}" if zipcode.nil?
      end
    rescue Exception => e
      # Second chance: Try to geocode the address
      result = Geocoder.yahoo(str)
      
      if result and result[:city] != '' and result[:state] != ''
        city, state = result[:city], result[:state]
        zipcode = ZipCode.find_by_city_and_state(city.capitalize, state.upcase)
      end
      
      throw e unless zipcode
    end
    
    zipcode
  end
  
  def self.contains_zip?(str)
    str.split(/,| /).detect { |token| self.is_zip?(token) }
  end
  
  # returns non-nil if the given string appears to be a zipcode
  # only handles 5-digit zips
  def self.is_zip?(zip)
    zip =~ /[0-9][0-9][0-9][0-9][0-9]/
  end
  
  # Returns true if the first point is within radius miles from the center point.
  # All angles should be measured in degrees.
  def self.within_range?(lat, long, center_lat, center_long, radius)
    # Convert to radians
    lat = lat * (Math::PI / 180)
    long = long * (Math::PI / 180)
    center_lat = center_lat * (Math::PI / 180)
    center_long = center_long * (Math::PI / 180)
    
    # This is the spherical law of cosines
    x = (Math.sin(lat) * Math.sin(center_lat)) + (Math.cos(lat) * Math.cos(center_lat) * Math.cos(long - center_long))
    
    if x <= -1 or x >= 1
      # Cannot calculate acos
      distance = 0
    else
      distance = Math.acos(x) * 3963 # Radius of earth in miles
    end
    
    distance <= radius
  end
  
  module ActsAsLocation
    def city_state_zip=(str)
      zipcode = Address::parse_city_state_zip(str)
      if zipcode
        # TODO For now, don't set the zipcode if the user didn't specify.
        # Deal with more than one zip per city.
        self.zipcode = Address::contains_zip?(str) ? zipcode.zip : ""
        self.state = zipcode.state
        self.city = zipcode.city
        self.longitude = zipcode.longitude
        self.latitude = zipcode.latitude
      else
        self.zipcode = self.state = self.city = self.latitude = self.longitude = ""
      end
    end
    
    def city_state_zip
      return self.zipcode if self.zipcode != ""
      return self.city + ", " + self.state if self.city != "" and self.state != ""
      return ""
    end
  end
end