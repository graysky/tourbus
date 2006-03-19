# Links that a Band can have to other services like MySpace, iTunes, their own homepage, etc.
class Link < ActiveRecord::Base

  LINK_TYPES = [
        ["---", -1],
        ["MySpace", 0], 
        ["Homepage", 1], 
      ] unless const_defined?("LINK_TYPES")
  

  TYPES = {
    :myspace => "MySpace",
    :homepage => "Homepage",
    :other => "Other"
  }
  
  def self.Types
    LINK_TYPES
  end
  
  # Form the URL for this link
  def url
    return "http://fake.com"
  end

end
