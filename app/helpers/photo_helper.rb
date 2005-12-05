module PhotoHelper
  def photo_thumbnail_table(photos)
    return if photos.nil? or photos.empty?
    
    html = "<table class='photo_thumbnail_table'>"
    i = 0
    for photo in photos
      html << "<tr>" if i % 2 == 0
      html << "<td><img src='" + photo.relative_path('thumbnail') + "'/></td>"  
      html << "</tr>" if i % 2 == 1 or i == photos.length - 1
      
      i += 1
    end
    
    html << "</table>"
  end
end