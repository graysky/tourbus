# Controller to build a badge for inclusion on a band or fan's site.
class BadgeController < ApplicationController
  layout "public"
  
  # Default page
  def index
    id = obj = nil
    @shows = []
    @base_badge_url = ""
    
    # Try to pull an ID out of the params
    begin
      if id = params['fan']
        obj = Fan.find(id)
        @base_badge_url = badge_url(public_fan_url(obj))
      elsif id = params['band']
        obj = Band.find(id)
        @base_badge_url = badge_url(public_band_url(obj))
      elsif id = params['venue']
        obj = Venue.find(id)
        @base_badge_url = badge_url(public_venue_url(obj))
      elsif logged_in_fan
        # Use logged in fan if available
        obj = logged_in_fan
        @base_badge_url = badge_url(public_fan_url(obj))
      elsif logged_in_band
        obj = logged_in_band
        @base_badge_url = badge_url(public_band_url(obj))
      else
        obj = Fan.mike    
        @shows = obj.upcoming_shows
        # Render a preview of a badge
        render :template => "badge/preview"
        return
      end
    rescue  ActiveRecord::RecordNotFound => exc
      flash.now[:error] = "Could not find the object with ID: #{id}"
    end

    # Prepend the site
    @base_badge_url = "http://tourb.us" + @base_badge_url
    
    return if obj.nil?
    
    # CSS styles to pick from
    @styles = {}
    @styles['simple'] = get_badge_style("badge/badge_style_simple")
    @styles['tourbus'] = get_badge_style("badge/badge_style_tourbus")
    @styles['blackwhite'] = get_badge_style("badge/badge_style_blackwhite")
    @styles['pink'] = get_badge_style("badge/badge_style_pink")
    @styles['blue'] = get_badge_style("badge/badge_style_blue")
    
    @shows = obj.upcoming_shows
  end
  
  # Serve up the badge style sheets
  def style
    name = params[:style]
    
    badge_name = "badge/badge_style_#{name}"
    
    css = get_badge_style(badge_name)
    
    @headers["Content-Type"] = "text/css"
    render :text => css
  end
  
  protected

  # Get the badge style from the partial and remove new lines  
  def get_badge_style(name)
    css = render_to_string(:partial => name, :layout => false)
    
    # Remove new lines
    css.gsub!(/\n/, '')
    css.gsub!(/\r/, '')
    css.gsub!(/\r\n/, '')
    return css
  end
  
  # Form the URL that points to the badge
  def badge_url(base_url)
    # NOTE: Needs to match how fans/bands declare it
    return base_url + "/js"
  end
end
