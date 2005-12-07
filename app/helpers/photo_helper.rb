module PhotoHelper
  def photo_navigation_table(base)
    photos = base.subject.photos
    if photos.nil? or photos.empty?
      return "There are no other photos"
    end
    
    html = "<table class='photo_table'>"
    html << "<tr>"
    index = photos.index(base)
    html << "<td>"
    if index > 0
      html << photo_img_tag(photos[index - 1], 'thumbnail')
      action = url_for :photo_id => photos[index - 1].id
      html << "<br/><span><a href='#{action}'>Prev</a></span>"
    else
      html << "x"
    end
    html << "</td>"
    html << "<td>"
    if index < photos.length - 1
      html << photo_img_tag(photos[index + 1], 'thumbnail')
      action = url_for :photo_id => photos[index + 1].id
      html << "<br/><span><a href='#{action}'>Next</a></span>"
    else
      html << "x"
    end
    html << "</td>"
    html << "</tr>"
    
    html << "</table>"
  end
  
  def photo_img_tag(photo, version)
   "<img src='" + photo.relative_path(version) + "'/>"
  end
  
  # max_rows == nil for no maximum
  def photo_preview_table(photos, max_rows, max_cols)
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
      html << photo_preview_cell_contents(photo)
      html << "</td>"
      html << "</tr>" if i % max_cols == max_cols - 1 or i == max_photos - 1
      
      i += 1
      break if i == max_photos
    end
    
    html << "</table>"
  end
  
  def photo_preview_cell_contents(photo, version = 'preview')
      # TODO Broken. Need the right link for band and fan homepages...
      if version == 'normal'
        full_photo_link = photo.relative_path
      else
        full_photo_link = url_for :controller => full_photo_controller(photo), :action => "photo", :photo_id => photo.id
      end
      
      html = "<a href='#{full_photo_link}'><img src='" + photo.relative_path(version) + "'/></a>"
      from = truncate(photo.created_by_name, 16)
      from_url = public_url_for_creator(photo)
      html << "<br/><span>From <a href='#{from_url}'>#{from}</a></span>"
  end
  
  def photo_preview_page_link(photo)
    url_for :controller => full_photo_controller(photo), :action => "photos"
  end
  
  def full_photo_controller(photo)
    # Bands and fans are special
    if photo.band
      photo.band.band_id
    #elsif photo.fan
    # TODO Pictures of fan?
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
end