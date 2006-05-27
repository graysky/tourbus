# Schema as of Thu May 04 23:27:20 Eastern Standard Time 2006 (schema version 33)
#
#  id                  :integer(11)   not null
#  applies_to          :string(255)   default(), not null
#  teaser              :text          default(), not null
#  message             :text          default(), not null
#  title               :text          
#  updated_at          :datetime      
#  created_at          :datetime      
#  expire_at           :datetime      not null
#

# Represents an Announcement to inform users about site updates
class Announcement < ActiveRecord::Base

  ANNOUNCE_TYPES = [
        ["all", "all"],
        ["fan", "fan"], 
        ["band", "band"],
      ] unless const_defined?("ANNOUNCE_TYPES")

  def self.Types
    return ANNOUNCE_TYPES
  end

  def self.Band
    "band"
  end
  
  def self.Fan
    "fan"
  end
  
  def self.All
    "all"
  end 

end
