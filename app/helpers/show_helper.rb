module ShowHelper
  def show_results(shows)
    out = ""
    for show in shows
      out << "<div>"
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
      out << "</div>"
    end
    
    # No show results, so put friendly text
    if shows == nil || shows.empty?
      out << "<div><strong>No shows listed</strong></div>"
    end
    
    return out
  end
  
  def show_controls(action)
    out = ""
    out << link_to_unless(params[:show_display] == nil || params[:show_display] == "upcoming",
                          "Upcoming", :action => action, :show_display => :"upcoming")
    out << " | "
    out << link_to_unless(params[:show_display] == "recent",
                          "Recent", :action => action, :show_display => "recent")
    out << " | "
    out << link_to_unless(params[:show_display] == "all",
                          "All", :action => action, :show_display => "all")
    out
  end
end
