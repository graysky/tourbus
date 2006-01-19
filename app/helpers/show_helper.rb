module ShowHelper
  def show_results(shows, show_map, show_venue = true)
    if true
      out = ""
      out << "<table class='show_table'><tr>"
      out << "<th>Date</th><th>Time</th><th>Bands</th><th width='100px'>Venue</th><th><nobr>More Info</nobr></th>"
      out << "</tr>"
      
      last_date = nil
      for show in shows
        out << "<tr>"
        out << col("<nobr>" + friendly_date(show.date) + "</nobr>")
        out << col(friendly_time(show.date))
        out << col("<strong>" + show.bands.map { |band| band.name }.join(", ") +"</strong>")
        out << col(show.venue.name)
        out << col("<strong>" + link_to("Click Here", :controller => "show", :action => "show", :id => show.id) + "</strong>" )
        out << "</tr>"
      end
      
      out << "</table>"
      return out
    end

	# FIXME NON-TABLE VERSION
    out = ""
    for show in shows
      out << "<div>"
      out << "<table><tr><td valign='top'>"
      
      if show_map
        # Draw a marker that links back to the map and shows a info bubble
        out << "<a href='#map_top'><img onclick='showInfoWindow(#{show.venue.id})' src='/images/default_marker.png'/></a></td><td>"
      end 
      
      out << "<strong>" + friendly_date(show.date) + "</strong>&nbsp;&nbsp;"
      out << friendly_time(show.date)
      if show.cost != ""
        out << ", " + show.cost
      end
      out << "<br/>"
      
      title = show.title
      if title == ""
        # TODO Optimize this by saving this string to the db when the show is saved
        title = show.bands.map { |band| band.name }.join("/")
      end
      
      out << "<b>" + link_to(title, :controller => "show", :action => "show", :id => show.id) + "</b>"
      out << "<br/>"
      if show_venue
        out << "at "
        out << link_to(show.venue.name, :controller => "venue", :action => "show", :id => show.venue.id) + "<br/>"
      end
      out << show.description + "<br/>"
      out << "</td></tr></table>"
      out << "</div>"
    end
    
    # No show results, so put friendly text
    if shows == nil || shows.empty?
      out << "<div><strong>No shows listed</strong></div>"
    end
    
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
