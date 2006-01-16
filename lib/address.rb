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
    name_or_abbrev.upcase!
    val = STATE_ABBREVS.find { |abbrev| abbrev == name_or_abbrev }
    return val if val
    
    STATES[name_or_abbrev.downcase]
  end
  
  # Parse a string that contains a city and state AND/OR zipcode
  # Returns a zipcode object
  # If no zip given, an arbitrary zip code is chosen from the city
  # FIXME Should be the center
  # Throws an exception if it cannot be recognized
  def self.parse_city_state_zip(str)
    city_words = []
    city = state = zip = nil
    
    str.split(/,| /).each do |token|
      if (state_abbrev = self.state_abbrev(token))
        state = state_abbrev
      elsif self.is_zip?(token)
        zip = token
      else
        city_words << token
      end
    end
    
    city = city_words.join(" ")
    raise "Invalid address: Missing city or zipcode" if city == "" and zip.nil?
    raise "Invalid address: Missing state" if state.nil? and zip.nil?
    
    # If we have a zip code look it up and use it. Otherwise, try to use the city and state
    if not zip.nil?
      zipcode = ZipCode.find_by_zip(zip)
      raise "Invalid address: Unknown zipcode: #{zip}" if zipcode.nil?
    else
      zipcode = ZipCode.find_by_city_and_state(city.capitalize, state.upcase)
      raise "Invalid address: Unknown city and state" if zipcode.nil?
    end
    
    zipcode
  end
  
  # returns non-nil if the given string appears to be a zipcode
  # only handles 5-digit zips
  def self.is_zip?(zip)
    zip =~ /[0-9][0-9][0-9][0-9][0-9]/
  end

end