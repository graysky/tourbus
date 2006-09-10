class FanServices < ActiveRecord::Base
  belongs_to :fan
  
  def self.poll_lastfm_faves
    services = FanServices.find(:all, :conditions => 'lastfm_poll = 1', :include => :fan)
    
    services.each do |s|
      if s.lastfm_username && s.lastfm_username.strip != ''
        fan = s.fan
        
        begin
          top = LastFm.top_50_bands(s.lastfm_username.strip)
          wishlist, bands = WishListBand.segment_wishlist_bands(top)
          
          if bands
            bands.each do |band|
              if !fan.favorite?(band) && !fan.removed_favorite?(band)
                logger.info "Add favorite: #{fan.name} => #{band.name}"
                fan.add_favorite(band, FavoriteBandEvent::SOURCE_LASTFM_POLL)
              end
            end
          end
        rescue Exception => e
          logger.error(e)
        end
        
        # Only one last.fm query allowed per second, so be careful
        sleep(1)
      end
    end
    
    return nil
  end 
end
