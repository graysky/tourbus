# Schema as of Thu Mar 23 23:26:05 Eastern Standard Time 2006 (schema version 19)
#
#  id                  :integer(11)   not null
#  name                :string(255)   
#  data                :string(255)   
#  band_id             :integer(10)   
#  updated_at          :datetime      
#  created_at          :datetime      
#

# Links that a Band can have to other services like MySpace, iTunes, their own homepage, etc.
class Link < ActiveRecord::Base

  belongs_to :band

  # Form the URL for this link
  def url
    # Clean up to be valid link
    return self.data
  end
  
  # Return a qualified URL with http:// on the front if it doesn't already have it
  def clean_url(url)
    return url if url.nil? or url.empty?
      
    # Qualify website URL if needed
    if url !~ /http/
      url = "http://" + url
    end
    
    return url  
  end
  
  # Set this link's URL to the specified URL
  # and set the link name to a reasonable guess if not specified
  def guess_link(url, name = nil)
  
    # Set the URL
    self.data = clean_url(url)
    
    if !name.nil? and !name.empty?
      self.name = name
    else
      # Attempt to guess the name.
      guess = "Official Website"
      
      # Make better guesses
      if self.data =~ /myspace.com/
        guess = "MySpace Profile"
      elsif self.data =~ /purevolume.com/
        guess = "PureVolume Profile"
      end
      
      self.name = guess
    end
  end
  
end
