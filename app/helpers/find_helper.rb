module FindHelper
  def search_results_suffix(type)
    return " (nationwide)" if @session[only_local_session_key(type)] == 'false'
    return " (near #{session[:location]})"
  end
  
  def show_prefix_browse
    out = "<div id='prefix_browse'><center>"
    
    if params[:prefix].blank?
      out << "<span>All</span>"
    else
      out << link_to("All", :action => params[:action])
    end
    
    out << "&nbsp;"
    
    for letter in 'A'..'Z'
      current = params[:prefix] && params[:prefix].downcase == letter.downcase
      if current
        out << "<span>#{letter}</span>"
      else
        out << link_to(letter, :action => params[:action], :prefix => letter.downcase)
      end
      
    end
    
    out << "</center></div>"
    out
  end
end
