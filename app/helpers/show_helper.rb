module ShowHelper
  def show_results(shows, show_map, show_venue = true)
    # TODO Make text specific to context
    if shows == nil || shows.empty?
      return "<div><strong>No shows found</strong></div>"
    end
    
    out = ""
    out << "<table class='show_table'><tr>"
    out << "<th>Date</th><th>Time</th><th>Bands</th><th width='100px'>Venue</th><th><nobr></nobr></th>"
    out << "</tr>"
    
    last_date = nil
    for show in shows
      date = friendly_date(show.date)
      if last_date == date
        date = ""
      else
        last_date = date
      end
      
      out << "<tr>"
      out << col("<nobr>" + date + "</nobr>")
      out << col(friendly_time(show.date))
      out << col("<strong>" + show.bands.map { |band| band.name }.join(", ") +"</strong>")
      out << col(show.venue.name)
      out << col("<strong>" + link_to("Details", :controller => "show", :action => "show", :id => show.id) + "</strong>" )
      out << "</tr>"
    end
    
    out << "</table>"
    return out
  end
  
  def write_show_map_points(shows_by_date)
    # Form hash of arrays by venue
    shows_by_venue = {}
    for show in shows_by_date
        shows = shows_by_venue[show.venue]
        if !shows
          shows = []
          shows_by_venue[show.venue] = shows
        end
        
        shows << show
    end
    
    out = ""
    shows_by_venue.each do |venue, shows|
      out << "{"
      out << "var latitude = #{venue.latitude};"
	  out << "var longitude = #{venue.longitude};"
	  out << "var point = new GPoint(longitude, latitude);"
	  
      div_class = shows.size > 1 ? "map_info" : "map_info"
      out << "var html = \"<div class='#{div_class}'>\";"
      
      out << map_info_venue_details(venue)
      out << "html += '<br/>';"
        
      for show in shows
        out << map_info_show_date(show)
        out << "html += '<br/><br/>';"
      end 
      
      out << "var marker = createMarker(point, html, #{venue.id});"
      out << "map.addOverlay(marker);"
      
      out << "}"
    end
    
    out
  end
  
  def map_list_toggle(action)
    out = ""
    out << link_to_unless(params[:show_map] == nil || params[:show_map] == "false",
                          "Hide Map", :action => action, :show_map => "false", :show_display => params[:show_display])
    out << " | "
    out << link_to_unless(params[:show_map] == "true",
                          "Show Map", :action => action, :show_map => "true", :show_display => params[:show_display])
  end
  
  def show_controls(action)
    out = ""
    out << link_to_unless(params[:show_display] == nil || params[:show_display] == "upcoming",
                          "Upcoming", :action => action, :show_display => "upcoming", :show_map => params[:show_map])
    out << " | "
    out << link_to_unless(params[:show_display] == "recent",
                          "Recent", :action => action, :show_display => "recent", :show_map => params[:show_map])
    out << " | "
    out << link_to_unless(params[:show_display] == "all",
                          "All", :action => action, :show_display => "all", :show_map => params[:show_map])
    out
  end
  
  def can_edit_show(show)
    return if not logged_in?
    
    show.created_by_system? or 
    show.created_by_fan or 
    (logged_in_band and show.bands.detect {|b| b.id == logged_in_band.id}) or
    (logged_in_band and logged_in_band == show.created_by_band)
  end
  
  #########
  # Private
  #########
  private
  
  def col(contents)
    "<td>#{contents}</td>"
  end
  
  def map_info_show_date(show)
    out =  "html += '<strong>#{friendly_date(show.date)}</strong>&nbsp;&nbsp;';"
    out << "html += '<br/>#{friendly_time(show.date)}';"
  end
  
  def map_info_venue_details(venue)
	out =  "html += '<b>#{gmarker_fmt(venue.name)}</b><br/>';"
	out << "html += '#{gmarker_fmt(venue.address)}<br/>';"
	out << "html += '#{gmarker_fmt(venue.city)}, #{gmarker_fmt(venue.state)} #{gmarker_fmt(venue.zipcode)} <br/>';"
  end
  
end
