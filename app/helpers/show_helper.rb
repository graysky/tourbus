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
      out << link_to(show.venue.name) + "<br/>"
      out << show.description + "<br/>"
      out << "</div>"
    end
    
    out
  end
  
  def show_controls
    
  end
end
