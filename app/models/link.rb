# Links that a Band can have to other services like MySpace, iTunes, their own homepage, etc.
class Link < ActiveRecord::Base

  # Form the URL for this link
  def url
    # Clean up to be valid link
    return self.data
  end

end