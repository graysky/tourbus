require_dependency "geocoder"

class BandController < ApplicationController
  include BandLoginSystem
  
  before_filter :login_required, :except => [:login]
  before_filter :find_band
  layout "public"
  
  def index
  end
  
  def login
    return if @request.get?
    
    if band = Band.authenticate(params['login'], params['password'])
      @session[:band] = band
      redirect_back_or_default(:action => "home")
    else
      @error_message  = "Login unsuccessful. Please check your username and password, and that " +
                        "your account has been confirmed."
    end
  end

  def logout
    session[:band] = nil
    redirect_to(:controller => "public", :action => "front_page")
  end

  # The the band homepage
  def home
    return if @request.get?
    save_band_profile("Profile information was successfully updated", "home")
  end
  
  # Contact info
  def contact
    return if @request.get?
    save_band_profile("Contact information was successfully updated", "contact")
  end
  
  def tours
    if @request.get?
      @tour = Tour.new
    else
      @tour = @band.tours.build(params[:tour])
      
      if @band.save
        flash[:notice] = 'Tour added'
        redirect_to(:action => "tours")
      end
    end
  end
  
  def shows
  end
  
  def add_show
    if @request.get?
      @show = Show.new
      @show.date = Time.now
      @venue = Venue.new
    else
      @show = Show.new(params[:show])
      
      # Get the new or existing venue
      new_venue = false
      if params[:venue_type] == "new"
        new_venue = true
        @venue = Venue.new(params[:venue])
        p @venue
      else
        begin 
          @venue = Venue.find(params[:selected_venue_id])
        rescue
          @venue = nil
        end
        
        if @venue.nil?
          @show.errors.add(nil, "Please select a venue or add a new one")
          @venue = Venue.new
          return
        end
      end
    
      # See if we can locate the venue's address
      if new_venue
        if @venue.zipcode == "" and @venue.city == ""
          @venue.errors.add(nil, "Please enter a city, state and zipcode")
          return
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
        else
          flash[:address_error] = true
          return
        end
      end
      
      @show.venue = @venue
      @band.play_show(@show, true)
      if !@band.save
        render :action => "add_show"
        return
      end
      
      flash[:notice] = 'Show added'
      redirect_to(:action => "shows")
    end
  end
  
  def venue_search
    begin
      name = params[:venue_search_term]
      @venue = Venue.new(params[:venue])
      conditions = venue_location_conditions
         
      if !name.nil? && name != ""
        conditions = ["#{conditions} and name like ?", "%#{name}%"]
      end
      
      @venue_pages, @venues = paginate :venues, 
                                       :conditions => conditions, 
                                       :order_by => "name DESC", 
                                       :per_page => 20
      
      if (@venue_pages.item_count == 0)
        params[:error_message] = "No results found"
      end
    rescue Exception => ex
      params[:error_message] = ex.to_s
    end
    
    render(:partial => "venue_results")
  end
  

  private
  
  def find_band
    session[:band] ||= Band.new
    @band = session[:band]
    @public_url = public_band_url
  end
  
  def save_band_profile(msg, redirect)
    @band.attributes = params[:band]
    if @band.save
      flash[:notice] = msg
      redirect_to(:action => redirect)
    end
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
