# Shared helper for some of the various portlets that appear on the front page
module PortletHelper


  # Get the URL for the band logo (thumbnail version), 
  # either a saved logo or the default.
  def get_band_logo_url(band)
  
    logo_url = nil
  
    # If the band has a saved logo, use that in a smaller size.
    # FileColumn seems to use the instance var in scope
    if !band.logo.nil?

		# Resize for an 45x45 thumbnail
		logo_url = url_for_image_column(band, "logo", :size => "45x45!", :crop => "1:1", :name => "thumb")
	else
		logo_url = '/images/unknown_thumb.gif'
    end
    
    return logo_url
  end
  
   def get_tiny_fan_logo_url(fan)
  
    logo_url = nil
    if !fan.logo.nil?

		# Resize for an 25x25 thumbnail
		logo_url = url_for_image_column(fan, "logo", :size => "25x25!", :crop => "1:1", :name => "tiny_thumb")
	else
		logo_url = '/images/unknown_tiny_thumb.jpg'
    end
    
    return logo_url
  end

end