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
