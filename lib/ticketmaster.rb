class TicketMaster

  PREFIX = "http://ticketsus.at/tourbus?DURL="
  MIN_BAND_FANS = 3
  MIN_SHOW_FANS = 1

  def TicketMaster.band_link(band, force = false)
    if band.tm_id.blank? && (band.num_fans >= MIN_BAND_FANS || force)
      # Show a generic search link
      return "#{PREFIX}http://www.ticketmaster.com/search?keyword=#{band.name}"
    elsif !band.tm_id.blank?
      # Go directly to the artist page
      return "#{PREFIX}http://www.ticketmaster.com/artist/#{band.tm_id}"
    end

    nil
  end
  
  def TicketMaster.show_link(show, force = false)
    return if show.bands.blank?
    return "#{PREFIX}http://www.ticketmaster.com/event/#{show.tm_id}" if !show.tm_id.blank?
    
    if ((show.num_attendees + show.num_watchers) >= MIN_SHOW_FANS) || force
      bands = show.bands.sort { |b1, b2| b2.num_fans <=> b1.num_fans }
      return TicketMaster.band_link(bands.first, true)
    end
    
    nil
  end
end