# The methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def states_for_select
    Address::STATE_ABBREVS
  end
  
  # List of mobile carriers
  def carriers_for_select
    MobileAddress::CARRIERS
  end
  
  def public_band_link(text, band = nil)
    link_to(text, public_band_url(band))
  end
  
  def public_fan_link(text, fan = nil)
    link_to(text, public_fan_url(fan))
  end

  def public_show_link(text, show)
    link_to(text, public_show_url(show))
  end

  def public_metro_link(text, metro)
    link_to(text, public_metro_url(metro))
  end

  def band_public_action(action)
    public_band_url + (action.nil? ? "" : "/" + action)
  end

  def simple_separator(text)
    "<div class='panel_header'><span class='title'>#{text}</span></div>"
  end

  # Escape double quotes so:
  # " becomes \"
  def escape_quotes(text)
    text.gsub(/"/, '\"')
  end

  def long_date(date)
    date.strftime("%A, %B %d, %Y")
  end

  # Output like: "Tues 9/15"
  def friendly_date(date)
    return "" if date.nil?
    day = date.strftime("%a")
    month = date.strftime("%m")
    dom = date.strftime("%d")
    year = date.strftime("%y")

    # Strip off any leading "0" padding
    month.sub!(/^0/, '')
    dom.sub!(/^0/, '')

    s = "#{day} #{month}/#{dom}/#{year}"
  end
  
  # Output like: "Tuesday 9/12"
  def friendly_date2(date)
    return "" if date.nil?
    day = date.strftime("%A")
    month = date.strftime("%m")
    month.sub!(/^0/, '')

    dom = date.strftime("%d")
    # Strip off any leading "0" padding
    dom.sub!(/^0/, '')
    s = "#{day} #{month}/#{dom}"
    return s
  end
  
  # Output like: "Tues 9/15/2007"
  def friendly_date3(date)
    return "" if date.nil?
    day = date.strftime("%a")
    year = date.strftime("%Y")
    month = date.strftime("%m").sub(/^0/, '')

    dom = date.strftime("%d").sub(/^0/, '')
    # Strip off any leading "0" padding
    #dom.sub!(/^0/, '')
    return "#{day} #{month}/#{dom}/#{year}"
  end
  
  def friendly_time(date)
    return "" if date.nil?
    s = date.strftime("%I:%M%p")
    # Strip off any leading "0" padding
    s.sub!(/^0/, '')
    return s
  end
  
  # Date like: 12.8.07
  def simple_date(date)
    year = date.strftime("%y")
    month = date.strftime("%m")
    dom = date.strftime("%d")

    # Strip off any leading "0" padding
    month.sub!(/^0/, '')
    dom.sub!(/^0/, '')
    return "#{month}.#{dom}.#{year}"
    
  end

  # Date like: 12/8/07  
  def slash_date(date)
    return "" if date.nil?
    
    year = date.strftime("%y")
    month = date.strftime("%m")
    dom = date.strftime("%d")

    # Strip off any leading "0" padding
    month.sub!(/^0/, '')
    dom.sub!(/^0/, '')
    return "#{month}/#{dom}/#{year}"
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
  
  # Notification image table for error/info/success
  def img_label_table(img, label)
    "<table><tr><td valign='top'><img width='16px' height='16px' src=\"/images/#{img}\" onload='fixPNG(this)'/></td><td>#{label}</td></tr></table>"
  end
  
  # Creates a section with an image title
  # title_img MUST specify the file extension like PNG
  def section(title_img, width, height, action = nil)
    out = "<div class='panel_header'><table><tr>"
    # Apply PNG fix if needed
    if title_img =~ /.png/
      out << "<td width='580px'>#{image_tag(title_img, :height => height, :width => width, :onload => 'fixPNG(this)')}</td>"
    else
      out << "<td width='580px'>#{image_tag(title_img, :height => height, :width => width)}</td>"
    end  
    
    if action
      out << "<td valign='bottom' style='padding-right:12px'>#{action}</td>"
    end
    out << '</tr></table></div>'
  end
  
  def start_profile_info_box
    '<div class="info_box profile_box"><div>'
  end
  
  def end_profile_info_box
    '</div></div>'
  end
  
  # Override rails' built in form error reporting
  def error_messages_for(object_name, options = {})
    options = options.symbolize_keys
    object = instance_variable_get("@#{object_name}")
    unless object.errors.empty?
    
      items = content_tag("ul", object.errors.full_messages.collect { |msg| content_tag("li", msg) })
    
      out = "<div class='error'>" + img_label_table("exclamation.png", "We found #{pluralize(object.errors.count, 'error')} on this form! #{items}") + "</div>"
      
        #out << content_tag("ul", object.errors.full_messages.collect { |msg| content_tag("li", msg) })), "id" => options[:id] || "errorExplanation", "class" => options[:class] || "errorExplanation"
      return out
    end
  end
  
  # link to unless its the current page or one of the actions given
  def link_to_unless_action(name, actions = [], options = {}, html_options = {}, *parameters_for_method_reference, &block)
    current = current_page?(options) || actions.include?(params[:action])
    link_to_unless current, name, options, html_options, *parameters_for_method_reference, &block
  end
  
  def link_to_unless_current_action(name, options = {}, html_options = {}, *parameters_for_method_reference)
    link_to_unless current_page?(options) || params[:action] == options[:action], name, options, html_options, parameters_for_method_reference
  end
  
  # Return the META description for a page, with optional subject. 
  # Specifying subject will make it more unique and help SEO
  # http://www.ragepank.com/articles/43/duplicate-content/
  def meta_desc(subject = nil)
    base = " Visit tourb.us: Track your favorite bands, get reminders before concerts, find new live music, post music reviews and photos of shows."
      
    if subject.kind_of?(Band)
      return "Track upcoming concerts and shows for #{subject.name}." + base
    elsif subject.kind_of?(Venue)
      return "Concerts and shows at #{subject.name} in #{subject.city}, #{subject.state}." + base
    elsif subject.kind_of?(Show)
      s = "Concert details for #{subject.name} at #{subject.venue.name} in #{subject.venue.city}." + base
      s.gsub!(/\//, ', ') # Change "Band1/Band2" to "Band1, Band2"
      return s
    else
      # Perhaps we should randomize this?
      default = "tourb.us is a better way to find live music!"
      return default + base
    end    
  end
  
  # Return the META keywords for a page, with optional subject. 
  def meta_keywords(subject = nil)
    base = "live music, concert tracking, local music, bands, shows, clubs, concerts, tour, venues, reminders, tickets, itunes, last.fm, tourbus, tourb.us"
    
    if subject.kind_of?(Band)
      return "#{subject.name}, " + base
    elsif subject.kind_of?(Venue)
      return "#{subject.name}, #{subject.city}, #{subject.state}, " + base
    elsif subject.kind_of?(Show)
      s = "#{subject.name}, #{subject.venue.name}, #{subject.venue.city}, " + base
      s.gsub!(/\//, ', ') # Change "Band1/Band2" to "Band1, Band2"
      return s
    else
      return base
    end
  end
  
  def amazon_link(band)
    return "" if band.num_fans == 0
    name = band.name.gsub(" ", "+")
    url = "http://www.amazon.com/s/ref=nb_ss_dmusic/?tag=tourbus-20&url=search-alias%3Ddigital-music&field-keywords=#{name}"
    link_to("Listen @ Amazon!", url)
  end
end