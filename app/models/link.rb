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

  # Form the URL for this link
  def url
    # Clean up to be valid link
    return self.data
  end

end
