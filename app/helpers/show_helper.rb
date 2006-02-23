module ShowHelper
  def show_results(shows, show_map, show_venue = true)
    return if shows == nil || shows.empty?
     
    out = "<div class='search_results'>"
    index = 0
    for show in shows
      out << render(:partial => "shared/show_search_result", 
                    :locals => { :show => show, :index => index, :show_map => show_map, :show_venue => show_venue })
      index += 1
    end
    out << "</div>"
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
    if (params[:show_map] == nil || params[:show_map] == "false")
      link_to(image_tag("show_map"), :action => action, :show_map => "true", :show_display => params[:show_display])
    else
      link_to(image_tag("show_list"), :action => action, :show_map => "false", :show_display => params[:show_display])
    end
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
