module BandHelper
  def external_map_code
    def_height = "300px"
    def_width = "400px"
    url = public_band_url + "/external_map?height=#{def_height}&width=#{def_width}"
    
    "<iframe src='#{url}' height='#{def_height}' width='#{def_width}' style='border:none'></iframe>"
  end
  
  def band_results(bands)
    out = "<div class='search_results'>"
    
    index = 0
    for band in bands
      out << render(:partial => "shared/band_search_result",
                    :locals => { :band => band, :index => index })
      index += 1
    end
    
    out << "</div>"
  end
end
