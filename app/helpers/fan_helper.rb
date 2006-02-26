module FanHelper
  def tiny_fan_results(fans)
    out = "<div class='fan_preview_list'>"
    index = 0
	for fan in fans 
	  out << render(:partial => "shared/tiny_fan_search_result", :locals => { :fan => fan, :index => index })
	  index += 1
	end	
    out << "</div>"
  end
end
