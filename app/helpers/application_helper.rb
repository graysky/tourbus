# The methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def states_for_select
    Address::STATE_ABBREVS
  end
  
  def public_band_link(text, band = nil)
    link_to(text, public_band_url(band))
  end
  
  def public_fan_link(text, fan = nil)
    link_to(text, public_fan_url(fan))
  end

  def simple_separator(text)
    "<div class='panel_header'><span class='title'>#{text}</span></div>"
  end

  def friendly_date(date)
    date.strftime("%a %m/%d")
  end
  
  def friendly_time(date)
    date.strftime("%I:%M%p")
  end
  
  def simple_date(date)
    date.strftime("%m.%d.%y")
  end
  
  def slash_date(date)
    date.strftime("%m/%d/%y")
  end
  
  def time_select(var, default_hour = nil, default_minute = nil, default_ampm = nil)
    out = "<select id=\"#{var}_hour\" name=\"#{var}[time_hour]\">"
    (1..12).each do |hour|
      default = default_hour.nil? ? 7 : default_hour
      selected = hour == default ? "SELECTED" : ""
      out += "<option value=\"#{hour}\" #{selected}>#{hour}</option>\n"
    end
    out += "</select> : "
    
    out += "<select id=\"#{var}_minute\" name=\"#{var}[time_minute]\">"
    ["00", "15", "30", "45"].each do |minute|
      default = default_minute.nil? ? "" : default_minute
      selected = default.to_s == minute ? "SELECTED" : ""
      out += "<option value=\"#{minute}\" #{selected}>#{minute}</option>"
    end
    out += "</select> "
    
    is_pm = true if default_ampm.nil? || default_ampm != "AM"
    
    out += "<select id=\"#{var}_ampm\" name=\"#{var}[time_ampm]\">"
    out += "<option value=\"AM\">AM</option><option value=\"PM\" selected=\"#{is_pm}\">PM</option>"
    out += "</select>"
    out
  end
  
  def date_select_with_calendar(var, field)
    # First add the text field
    out = text_field(var, field, "readonly" => true)
    
    # The trigger button
    trigger_id = "cal_trigger"
    out += "\n<img id=\"#{trigger_id}\" src=\"/images/calendar.gif\"/>"
    
    # The calenda setup javascript
    out += <<END_JS
      <script type="text/javascript">
		Calendar.setup(
  		  {
  		    inputField : "#{var}_#{field}",
  		    ifFormat : "%B %d, %Y",
  		    button : "#{trigger_id}"
  		  }
		);
	  </script>
END_JS
    
  end
  
end
