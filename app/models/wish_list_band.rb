class WishListBand < ActiveRecord::Base
  def before_save
    super
    self.short_name = Band.name_to_id(self.name)
  end
  
  # Return two arrays: An array of names that aren't bands in the system
  # and should be added to a wishlist, and an array of Bands that are in
  # the db.
  def self.segment_wishlist_bands(names)
    wishlist = []
    bands = []
    
    names.each do |name|
      band = Band.find_by_short_name(Band.name_to_id(name))
      
      if band.nil? and name.downcase.starts_with?('the ')
        # Try without 'the'
        band = Band.find_by_short_name(Band.name_to_id(name[4..-1]))
      end
      
      if band.nil?
        # Try with 'the
        band = Band.find_by_short_name(Band.name_to_id('the' + name))
      end
      
      if band.nil? and name.include?('&')
        # Replace ampersand with 'and'
        band = Band.find_by_short_name(Band.name_to_id(name.gsub(/&/, 'and')))
      end
        
      if band.nil? and name.include?(' and ')
        # Replace 'and' with &
        band = Band.find_by_short_name(Band.name_to_id(name.gsub(/ and /, ' & ')))
      end
      
      bands << band if band
      wishlist << name unless band
    end
    
    return wishlist.uniq, bands.uniq
  end
end
