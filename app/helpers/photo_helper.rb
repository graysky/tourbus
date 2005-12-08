module PhotoHelper
  def photo_navigation_table(base, showing_creator)
    photos = showing_creator ? base.creator.photos : base.subject.photos
    if photos.nil? or photos.empty? or photos.length == 1
      return "<span>There are no other photos</span><br/><br/>"
    end
    
    html = "<table class='photo_table'>"
    html << "<tr>"
    index = photos.index(base)
    html << "<td>"
    if index > 0
      html << photo_img_tag(photos[index - 1], 'thumbnail')
      action = url_for :photo_id => photos[index - 1].id, :showing_creator => showing_creator
      html << "<br/><span><a href='#{action}'>Prev</a></span>"
    end
    html << "</td>"
    html << "<td>"
    if index < photos.length - 1
      html << photo_img_tag(photos[index + 1], 'thumbnail')
      action = url_for :photo_id => photos[index + 1].id, :showing_creator => showing_creator
      html << "<br/><span><a href='#{action}'>Next</a></span>"
    end
    html << "</td>"
    html << "</tr>"
    
    html << "</table>"
  end
  
  def photo_img_tag(photo, version)
   "<img src='" + photo.relative_path(version) + "'/>"
  end
  
  # max_rows == nil for no maximum
  def photo_preview_table(photos, max_rows, max_cols, showing_creator)
    html = "<table class='photo_table' id='photo_preview_table'>"
    
    if photos.nil? or photos.empty?
      # Write out the first row for use by the javascript updating functions
      html << "<tr></tr></table>"
      return html
    end
    
    max_photos = max_rows ? max_rows * max_cols : photos.length
    i = 0
    for photo in photos
      html << "<tr>" if i % max_cols == 0
      html << "<td>"
      html << photo_preview_cell_contents(photo, 'preview', showing_creator)
      html << "</td>"
      html << "</tr>" if i % max_cols == max_cols - 1 or i == max_photos - 1
      
      i += 1
      break if i == max_photos
    end
    
    html << "</table>"
  end
  
  def photo_preview_cell_contents(photo, version = 'preview', showing_creator = false)
      # TODO Broken. Need the right link for band and fan homepages...
      if version == 'normal'
        full_photo_link = photo.relative_path
      else
        full_photo_link = url_for :controller => full_photo_controller(photo, showing_creator), 
                                  :action => "photo", 
                                  :photo_id => photo.id, 
                                  :id => photo.subject.id
      end
      
      html = "<a href='#{full_photo_link}'><img src='" + photo.relative_path(version) + "'/></a>"
      if showing_creator
        # Show the subject of the picture
        from = truncate(photo.subject.name, 16)
        from_url = public_url_for_subject(photo)
        html << "<br/><span><a href='#{from_url}'>#{from}</a></span>"
      else
        # Show the creator
        from = truncate(photo.created_by_name, 16)
        from_url = public_url_for_creator(photo)
        html << "<br/><span>From <a href='#{from_url}'>#{from}</a></span>"
      end
  end
  
  def photo_preview_page_link(photo, showing_creator)
    url_for :controller => full_photo_controller(photo, showing_creator), :action => "photos", :id => photo.subject.id
  end
  
  def full_photo_controller(photo, showing_creator)
  
    if showing_creator
      if photo.created_by_fan
        return "fan/" + photo.created_by_fan.name
      elsif photo.created_by_band
        return photo.created_by_band.band_id
      end
    end
    
    if photo.band
      photo.band.band_id
    elsif photo.venue
      "venue"
    else
      params[:controller]
    end
  end
  
  def public_url_for_creator(photo)
    if photo.created_by_band
      public_band_url(photo.created_by_band)
    elsif photo.created_by_fan
      public_fan_url(photo.created_by_fan)
    end
  end
  
  # TODO This can be factored out, it is probably useful.
  def public_url_for_subject(photo)
    if photo.band
      public_band_url(photo.band)
    elsif photo.venue
      url_for :controller => "venue", :action => "show", :id => photo.venue.id
    end
  end
end