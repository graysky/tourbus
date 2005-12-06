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
      html << "<td><img src='" + photo.relative_path('preview') + "'/></td>"
      html << "</tr>" if i % max_cols == max_cols - 1 or i == max_photos - 1
      
      i += 1
      break if i == max_photos
    end
    
    html << "</table>"
  end
end