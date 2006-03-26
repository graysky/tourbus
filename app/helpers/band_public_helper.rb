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
  
  # Display the list of external links for a band
  def list_links(links)
    out = "<div class='links_list'><ul id='list_of_links'>"
  for link in links
      out << render(:partial => "single_link", :locals => { :link => link } )
  end  
    out << "</ul></div>"
  end
end
