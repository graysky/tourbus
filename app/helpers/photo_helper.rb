module PhotoHelper
  def photo_thumbnail_table(photos)
    return if photos.nil? or photos.empty?
    
    html = "<table class='photo_table'>"
    i = 0
    for photo in photos
      html << "<tr>" if i % 2 == 0
      html << "<td><img src='" + photo.relative_path('thumbnail') + "'/></td>"
      html << "</tr>" if i % 2 == 1 or i == photos.length - 1
      
      i += 1
    end
    
    html << "</table>"
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
      # TODO Broken. Need the right link for band and fan homepages...
      full_photo_link = url_for :action => "photo", :id => photo.id
      html << "<td><a href='#{full_photo_link}'><img src='" + photo.relative_path('preview') + "'/></a>"
      from = truncate(photo.created_by_name, 16)
      from_url = public_url_for_creator(photo)
      html << "<br/><center><span>From <a href='#{from_url}'>#{from}</a></span></center>"
      html << "</td>"
      html << "</tr>" if i % max_cols == max_cols - 1 or i == max_photos - 1
      
      i += 1
      break if i == max_photos
    end
    
    html << "</table>"
  end
  
  def public_url_for_creator(photo)
    if photo.created_by_band
      public_band_url(photo.created_by_band)
    elsif photo.created_by_fan
      public_fan_url(photo.created_by_fan)
    end
  end
end