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
  
  def enable_editing_link
    link_to_remote "Edit This Profile", :url => { :action => :enable_editing }
  end
  
  def disable_editing_link
    link_to_remote "Finished Editing", :url => { :action => :disable_editing }
  end
end
