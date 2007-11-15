class TicketMaster

  # Link IDs
  UNKNOWN = -1
  FAVES_EMAIL = 1
  REMINDER_EMAIL = 2
  RSS_ID = 3
  FIND_SHOWS = 4 # Find Shows Page
  FIND_BANDS = 5 # Popular Bands Page 
  BAND_PAGE = 6 # Individual pages...
  SHOW_PAGE = 7
  VENUE_PAGE = 8

  # Mins
  MIN_BAND_FANS = 3
  MIN_SHOW_FANS = 2

  # Get the TicketMaster URL prefix
  def self.get_prefix(link_id = TicketMaster::UNKNOWN)
    
    # Include the link id for tracking  
    if link_id != TicketMaster::UNKNOWN
      return "http://ticketsus.at/tourbus?LID=#{link_id.to_s}&DURL="
    else
      return "http://ticketsus.at/tourbus?DURL="
    end
  end

  def self.band_link(band, force = false, link_id = TicketMaster::UNKNOWN)
    if band.tm_id.blank? && (band.num_fans >= MIN_BAND_FANS || force)
      # Show a generic search link
      return "#{self.get_prefix(link_id)}http://www.ticketmaster.com/search?keyword=#{band.name}"
    elsif !band.tm_id.blank?
      # Go directly to the artist page
      return "#{self.get_prefix(link_id)}http://www.ticketmaster.com/artist/#{band.tm_id}"
    end

    nil
  end
  
  def self.show_link(show, force = false, link_id = TicketMaster::UNKNOWN)
    return if show.bands.blank?
    return "#{self.get_prefix(link_id)}http://www.ticketmaster.com/event/#{show.tm_id}" if !show.tm_id.blank?
    
    if ((show.num_attendees + show.num_watchers) >= MIN_SHOW_FANS) || force
      bands = show.bands.sort { |b1, b2| b2.num_fans <=> b1.num_fans }
      return TicketMaster.band_link(bands.first, true, link_id)
    end
    
    nil
  end
end