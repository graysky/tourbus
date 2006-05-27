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
  
  def fan_results(fans, show_status = false)
    out = "<div class='search_results'>"
    index = 0
    for fan in fans 
      out << render(:partial => "shared/fan_search_result", 
                    :locals => { :fan => fan, :index => index, :show_status => show_status })
      index += 1
    end
    
    if fans.size == 0
      out << "<div class='profile_section_no_content'>No friends yet, but no worries.</div>"
    end
      
    out << "</div>"
  end
  
  def outstanding_friend_requests
    out = ""
    count = 0
    
    out << "<table class='wishlist-table'><tr><th>Sent On</th><th>From</th><th>Message</th><th></th></tr>"
    @fan.incoming_friend_requests.each do |req|
      if !req.approved? && !req.denied?
        count += 1
        
        param = "?req=#{req.uuid}"
        confirm_url = url_for(:controller => 'fan', :action => :confirm_friend_request) + param
        confirm_img = "<img src='/images/accept.png' height='16' width='16' onload='fixPNG(this)'/>"
        deny_url = url_for(:controller => 'fan', :action => :deny_friend_request) + param
        deny_img = "<img src='/images/delete.png' height='16' width='16' onload='fixPNG(this)'/>"
        
        out << "<tr><td>#{friendly_date(req.created_on)}</td><td>#{req.requester.name}</td>"
        out << "<td>#{req.message}</td>"
        out << "<td>#{link_to confirm_img, confirm_url}"
        out << "&nbsp;&nbsp;#{link_to deny_img, deny_url}</td>"
        out << "</tr>"
        
      end
    end
    
    if count > 0
      out << "</table>"
    else
      out = "<div class='profile_section_no_content'> You don't have any friend requests that you need to respond to. </div>"
    end
    
    out
  end
  
end
