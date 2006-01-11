module BandHelper
  def external_map_code
    def_height = "300px"
    def_width = "400px"
    url = public_band_url + "/external_map?height=#{def_height}&width=#{def_width}"
    
    "<iframe src='#{url}' height='#{def_height}' width='#{def_width}' style='border:none'></iframe>"
  end
end
