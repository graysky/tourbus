module PhotoHelper
  def photo_navigation_table(base, showing_creator, type)
    if @flickr
      if type == Photo.Band
        photos = base.band.flickr_photos
      elsif type == Photo.Show
        photos = base.show.flickr_photos
      elsif type == Photo.Venue
        photos = base.venue.flickr_photos
      end
    else
      photos = showing_creator ? base.creator.photos : base.subject.photos
    end
    
    if photos.nil? or photos.empty? or photos.length == 1
      return "<span>There are no other photos</span><br/><br/>"
    end
    
    html = "<table class='photo_table'>"
    html << "<tr>"
    index = photos.index(base)
    html << "<td>"
    if index > 0
      action = url_for :photo_id => photos[index - 1].id, :showing_creator => showing_creator, :flickr => photos[index - 1].is_a?(FlickrPhoto)
      html << "<a href='#{action}'>" + photo_img_tag(photos[index - 1], photos[index - 1].is_a?(FlickrPhoto) ? 'square' : 'thumbnail') + "</a>"
      html << "<br/><span><a href='#{action}'>Prev</a></span>"
    end
    html << "</td>"
    html << "<td>"
    if index < photos.length - 1
      action = url_for :photo_id => photos[index + 1].id, :showing_creator => showing_creator, :flickr => photos[index + 1].is_a?(FlickrPhoto)
      html << "<a href='#{action}'>" + photo_img_tag(photos[index + 1], photos[index + 1].is_a?(FlickrPhoto) ? 'square' : 'thumbnail') + "</a>"
      html << "<br/><span><a href='#{action}'>Next</a></span>"
    end
    html << "</td>"
    html << "</tr>"
    
    html << "</table>"
  end
  
  def photo_img_tag(photo, version)
    if photo.is_a?(FlickrPhoto)
      if version == 'normal'
        src = photo.medium_source
      elsif version == 'square'
        src = photo.square_source
      else
        src = photo.thumbnail_source
      end
      
      "<img src='" + src + "'/>"
    else
     "<img src='" + photo.relative_path(version) + "'/>"
    end
  end
  
  # max_rows == nil for no maximum
  def photo_preview_table(photos, max_rows, max_cols, showing_creator, type = Photo.Band)
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
      html << photo_preview_cell_contents(photo, 'preview', showing_creator, type)
      html << "</td>"
      html << "</tr>" if i % max_cols == max_cols - 1 or i == max_photos - 1
      
      i += 1
      break if i == max_photos
    end
    
    html << "</table>"
  end
  
  # So messy... but this jams together user photos and flickr photos which are very different
  def photo_preview_cell_contents(photo, version = 'preview', showing_creator = false, type = Photo.Band)
    if photo.is_a?(FlickrPhoto)
      if version == 'normal'
        full_photo_link = photo.photopage_url
        src = photo.medium_source
      else
        full_photo_link = url_for :controller => full_photo_controller(photo, showing_creator, type), 
                                  :action => "photo", 
                                  :photo_id => photo.id,
                                  :flickr => true, 
                                  :id => flickr_photo_subject(photo, type)
        src = photo.thumbnail_source
      end
      
      html = "<a href='#{full_photo_link}'><img src='#{src}'/></a>"
      extra_link = nil
      extra_name = nil
      if type == Photo.Band && photo.show
        # Put the show date
        extra_name = friendly_date(photo.show.date)
        if version == 'normal'
          extra_name += " @ #{photo.show.venue.name}, #{photo.show.venue.city_state}"
        end
        extra_link = public_show_url(photo.show)
      elsif type == Photo.Band
        extra_name = friendly_date(photo.guess_show_date)
      elsif type == Photo.Show
        extra_name = photo.band.name
        if version == 'normal'
          extra_name += " @ #{photo.show.venue.name}, #{photo.show.venue.city_state}"
        end
        extra_link = public_band_url(photo.band)
      elsif type == Photo.Venue
        extra_name = photo.band.name
        if version == 'normal'
          extra_name += " (#{friendly_date(photo.show.date)})"
        end
        extra_link = public_band_url(photo.band)
      end
      
      if extra_link && extra_name
        html << "<br/><span><a href='#{extra_link}' style='font-size:10px'>#{extra_name}</a></span>"
      elsif extra_name
        html << "<br/><span>#{extra_name}</span>"
      end
      
      if logged_in_admin
        html << "<br/>" + link_to_remote("delete", :url => { :controller => :photo, :action => :mark_flickr_photo_inactive, :id => photo.id }, 
                                                 :success => "alert('gone')", :failure => "alert('error')")
      end
      
      html
    else
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
        # Show the creator
        from = truncate(photo.created_by_name, 16)
        from_url = public_url_for_creator(photo)
        html << "<br/><span>From <a href='#{from_url}' style='font-size:10px'>#{from}</a></span>"
      else
        # Show the subject of the picture
        name = photo.show ? date_venue_title(photo.subject) : photo.subject.name
        from = truncate(name, 16)
        from_url = public_url_for_subject(photo)
        html << "<br/><span><a href='#{from_url}' style='font-size:10px'>#{from}</a></span>"
      end
    end
  end
  
  def flickr_photo_subject(photo, type)
    if type == Photo.Band
      photo.band.id
    elsif type == Photo.Show
      photo.show.id
    elsif type == Photo.Venue
      photo.venue.id
    end
  end
  
  def photo_preview_page_link(photo, showing_creator, type)
    if photo.is_a?(FlickrPhoto)
      url_for :controller => full_photo_controller(photo, showing_creator, type), 
                             :action => "photos", :id => flickr_photo_subject(photo, type), :flickr => true
    else
      url_for :controller => full_photo_controller(photo, showing_creator), :action => "photos", :id => photo.subject.id
    end
  end
  
  def full_photo_controller(photo, showing_creator, type = Photo.Band)
  
    if photo.is_a?(FlickrPhoto)
      if type == Photo.Band
        return photo.band.short_name
      elsif type == Photo.Show
        return "show"
      elsif type == Photo.Venue
        return "venue"
      else
        return params[:controller]
      end
    end
  
    if showing_creator
      if photo.created_by_fan
        return "fan/" + photo.created_by_fan.name
      elsif photo.created_by_band
        return photo.created_by_band.short_name
      end
    end
    
    if photo.band
      photo.band.short_name
    elsif photo.venue
      "venue"
    elsif photo.show
      "show"
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
      url_for :controller => "venue", :action => "show", :id => photo.venue
    end
  end
end