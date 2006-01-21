# Shared helper for some of the various portlets that appear on the front page
module PortletHelper


  # Get the URL for the band logo (thumbnail version), 
  # either a saved logo or the default.
  def get_band_logo_url(band)
  
    logo_url = nil
  
    # If the band has a saved logo, use that in a smaller size.
    # FileColumn seems to use the instance var in scope
    if !band.logo.nil?

		# Resize for an 80x80 thumbnail
		logo_url = url_for_image_column(band, "logo", :size => "80x80>", :name => "thumb")
	else
		logo_url = 'images/unknown.jpg'
    end
    
    return logo_url
  end

end