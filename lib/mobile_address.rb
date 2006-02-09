# Helper module for dealing with mobile/SMS addresses
module MobileAddress

  # The US mobile carriers -- DO NOT EDIT unless code to calculate email
  # is also modified
  CARRIERS = [
        ["---", -1],
        ["AT&T Wireless", 0], 
        ["Cingular", 1], 
        ["Nextel", 2], 
        ["Sprint PCS", 3], 
        ["T-Mobile", 4], 
        ["Verizon", 5]
      ] unless const_defined?("CARRIERS")

  
  # Get the mobile address of this phone number on this carrier
  # or nil if we could not determine the number
  def self.get_mobile_email(number, carrier_type)

    if !valid_number?(number) or carrier_type == -1
      return nil
    end
  
    # This information comes from:
    # http://tinywords.com/mobile.html  
    case carrier_type
      
    # AT&T Wireless
    when 0
      return "#{number}@mmode.com"
    # Cingular
    when 1
      return "#{number}@cingularme.com"
    # Nextel
    when 2
      return "#{number}@messaging.nextel.com"
    # Sprint
    when 3
      return "#{number}@messaging.sprintpcs.com"
    # T-Mobile
    when 4
      return "#{number}@tmomail.net"
    # Verizon
    when 5
      return "#{number}@vtext.com"
    else
      # Invalid carrier type
      return nil
    end
  end

  # Try to determine if this is a valid phone number
  def self.valid_number?(num)
      
      # For now just make sure it is 10 digits long
      return true if num.length == 10      
  end

end