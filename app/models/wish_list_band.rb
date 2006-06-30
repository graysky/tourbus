class WishListBand < ActiveRecord::Base
  belongs_to :fan
  
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
  
  # Check all wishlists for bands that have been created in the last few days.
  def self.make_wishes_come_true
    new_bands = Band.find_created_since(Time.now - 30.days)
    return if new_bands.empty?
    
    in_clause = 'short_name in (' + new_bands.map { |band| "'" + band.short_name + "'" }.join(',') + ')'
    matches = self.find(:all, :conditions => [in_clause])
    
    # Build a hash from short_name -> band
    band_lookup = {}
    new_bands.each { |band| band_lookup[band.short_name] = band }
    
    # Stats
    num_fans = 0
    
    fans_bands = {}
    bands = []
    matches.each do |match|
      fan = match.fan
      band = band_lookup[match.short_name]
      
      # TODO Add a warning to the db somehow
      if band.nil?
        msg = "Fan: #{fan.name}, Wishlist band: #{match.short_name}"
        SystemEvent.warning("Could not find a band lookup", SystemEvent::WISHLIST, msg)
		next
      end
      
      
      # Add a fave and delete the wishlist band
      logger.info "Add fave #{band.name} for #{fan.name}"
      fan.add_favorite(band)
      WishListBand.delete(match.id)
      
      unless fans_bands[fan]
        fans_bands[fan] ||= []
        fans_bands[fan] << band
      end
      bands << band unless bands.include?(band)
    end
    
    # Save everything
    bands.each { |band| band.save! }
    fans_bands.each_key { |fan| fan.save! }
  
    # Notify fans
    fans_bands.each do |fan, bands|
      num_fans += 1
      FanMailer.deliver_wishlist_to_favorites(fan, bands)
    end
  
    SystemEvent.info("Found faves for #{num_fans} fans", SystemEvent::WISHLIST)
   
  end
end
