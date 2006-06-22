module BandPublicHelper

  # List of mobile carriers
  def link_types
    Link.Types
  end

  def band_bio_for_editing
    if @band.bio != ""
      "<div id='band_bio'>#{@band.bio}</div>"
    else
      "<div id='band_bio'></div>"
    end
  end
  
  def enable_editing_link(msg = 'Edit This Profile')
    link_to_remote msg, :url => { :action => :enable_editing }
  end
  
  def disable_editing_link
    link_to_remote "Finished Editing", :url => { :action => :disable_editing }
  end
  
  def help_us_improve_text
    if @logged_in_as_band
      "Edit Your Profile"
    else
      "Help Us Improve"
    end
  end
end
