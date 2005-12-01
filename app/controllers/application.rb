# The filters added to this controller will be run for all controllers in the application.
# Likewise will all the methods added be available for all controllers.
class ApplicationController < ActionController::Base
  model :band
  helper :debug
  helper_method :public_band_url
  helper_method :public_fan_url
  helper_method :logged_in?
  
  # Return the URL of the band, which can be passed
  # as an optional param.
  def public_band_url(band = nil)
    
    if band == nil
      band = session[:band]
    end
    
    url_for(:controller => '') + band.band_id
  end
  
  def public_fan_url
    url_for(:controller => '') + 'fan/' + session[:fan].name
  end
  
  # Whether there is a band or fan logged in
  def logged_in?
  
    if logged_in_fan
      return true
    elsif logged_in_band
      return true
    else
      return false
    end
  end
  
  ##########
  # Private
  ##########
  private
  # There is a band logged in
  def logged_in_band
    session[:band]
  end
  
  # There is a fan logged in
  def logged_in_fan
    session[:fan]
  end
  
  def prepare_new_show
    @show = Show.new
    @show.date = Time.now
    @venue = Venue.new
  end
  
  def create_new_show_and_venue
    @show = Show.new(params[:show])
      
    # Get the new or existing venue
    new_venue = false
    if params[:venue_type] == "new"
      new_venue = true
      @venue = Venue.new(params[:venue])
    else
      begin 
        @venue = Venue.find(params[:selected_venue_id])
      rescue
        @venue = nil
      end
      
      if @venue.nil?
        @show.errors.add(nil, "Please select a venue or add a new one")
        @venue = Venue.new
        raise
      end
    end
  
    # See if we can locate the venue's address
    if new_venue
      if @venue.zipcode == "" and @venue.city == ""
        @venue.errors.add(nil, "Please enter a city, state and zipcode")
        raise
      end
      
      if @venue.zipcode != ""
        addr = "#{@venue.address}, #{@venue.zipcode}"
      else
        addr = "#{@venue.address}, #{@venue.city}, #{@venue.state}"
      end
      
      result = Geocoder.geocode(addr)
      if result && !result["lat"].nil?
        @venue.latitude = result["lat"]
        @venue.longitude = result["long"]
      elsif not params[:ignore_address_error]
        params[:address_error] = true
        raise
      end
    end
    
    @show.venue = @venue
  end
  
  def venue_location_conditions()
    if ((@venue.city == "" || @venue.state == "") && @venue.zipcode == "")
      raise "Please enter a city/state or zipcode"
    end
    
    if (@venue.zipcode != "")
      return "zipcode = '#{@venue.zipcode}'"
    else
      return "city = '#{@venue.city}' and state = '#{@venue.state}'"
    end
  end
  
end