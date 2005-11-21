module ShowHelper
  def show_results(shows, show_map)
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
      if show.title != ""
        out << link_to(show.title)
        out << " at "
      end
      out << link_to(show.venue.name, :controller => "venue", :action => "show", :id => show.venue.id) + "<br/>"
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
end
