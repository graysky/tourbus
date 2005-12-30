class VenueController < ApplicationController
  before_filter :find_venue
  helper :show
  helper :map
  helper :tag
  helper :comment
  helper :photo

  layout "public"
  
  def add_dialog
    if @request.get?
      @venue = Venue.new
      
      # The initial name might be passed as a parameter
      @venue.name = params[:name]
      render :layout => "minimal"
      return
    end
    
    @venue = Venue.new(params[:venue])
    
    # Construct and verify the full address
    citystatezip = params[:citystatezip]
    addr = @venue.address
    addr += "," if addr != ""
    addr += citystatezip
    
    result = Geocoder.yahoo(addr)
    
    if result && result[:precision] == "address"
      @venue.latitude = result[:latitude]
      @venue.longitude = result[:longitude]
      @venue.city = result[:city]
      @venue.address = result[:address]
      @venue.state = result[:state]
      @venue.zipcode = result[:zipcode]
    elsif not params[:ignore_address_error]
      params[:address_error] = true
      render :layout => "minimal"
      return
    end
    
    if @venue.save
      render :action => :close_dialog, :layout => false
    end
  end
  
  def close_dialog
    
  end
  
  # For displaying a single venue
  def show
    # Determine the shows to display
    case params[:show_display]
    when nil, "upcoming"
      @shows = @venue.shows.find(:all, :conditions => ["date > ?", Time.now])
    when "recent"
      @shows = @venue.shows.find(:all, :conditions => ["date > ? and date < ?", Time.now - 1.week, Time.now])
    when "all"
      @shows = @venue.shows
    else
      flash[:error] = "Illegal value for show_display: " + params[:show_display]
    end
    
    # Record the page view
    inc_page_views(@venue)
  end
  
  # TODO FIXME - Can't use "@venue.name" because the venue's ID wans't passed in
  def photo
    render_component :controller => "photo", :action => "show_one", 
                     :params => {"photo_id" => params[:photo_id], "name" => @venue.name}
  end
  
  # Set the venue description
  def set_description
    @venue.description = params[:value]
    @venue.save
    render :text => @venue.description
  end
  
  # Set the venue url
  def set_url
    @venue.url = params[:value]
    @venue.save
    render :text => @venue.url
  end
  
  private
  
  # Find the venue from the ID param
  def find_venue
    # Look up the venue
    @venue = Venue.find_by_id(params[:id])
    
  end
  
end
