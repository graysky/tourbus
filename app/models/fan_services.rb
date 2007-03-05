class FanServices < ActiveRecord::Base
  belongs_to :fan
  
  def self.poll_lastfm_faves
    services = FanServices.find(:all, :conditions => 'lastfm_poll = 1', :include => :fan)
    
    services.each do |s|
      if s.lastfm_username && s.lastfm_username.strip != ''
        fan = s.fan
        
        begin
          # Get their top weekly artists
          weekly = LastFm.top_weekly_bands(s.lastfm_username.strip)
          wishlist, weekly_bands = WishListBand.segment_wishlist_bands(weekly)

          bands = []
          bands << weekly_bands if !weekly_bands.nil?

          # And their top overall artists
          sleep(1)
          top = LastFm.top_50_bands(s.lastfm_username.strip)
          wishlist, top_bands = WishListBand.segment_wishlist_bands(top)

          bands << top_bands if !top_bands.nil?
          bands.flatten!
          bands.uniq!
          
          if bands
            bands.each do |band|
              if !fan.favorite?(band) && !fan.removed_favorite?(band)
                OFFLINE_LOGGER.info "Add favorite: #{fan.name} => #{band.name}"
                fan.add_favorite(band, FavoriteBandEvent::SOURCE_LASTFM_POLL)
              end
            end
          end
        rescue Exception => e
          OFFLINE_LOGGER.error(e)
        end
        
        # Only one last.fm query allowed per second, so be careful
        sleep(1)
      end
    end
    
    return nil
  end 
end
