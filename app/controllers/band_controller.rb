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
    
    if band = Band.authenticate(@params['login'], @params['password'])
      @session[:band] = band
      redirect_back_or_default(:action => "home")
    else
      @error_message  = "Login unsuccessful. Please check your username and password, and that " +
                        "your account has been confirmed."
    end
    
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
      @tour = @band.tours.build(@params[:tour])
      
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
      @venue = Venue.new
    else
      @show = @band.shows.build(@params[:show])
      @venue = Venue.new(@params[:venue])
      
      # This is all temporary logic. We need to smart about detecting duplicate venues, etc
      addr = "#{@venue.address}, #{@venue.zipcode}"
      if addr.nil?
        flash[:notice] = 'Error with address'
        render :action => "shows"
        return
      else
        p addr
        result = Geocoder.geocode(addr)
        p result
        @venue.latitude = result["lat"]
        @venue.longitude = result["long"]
        if !@venue.save
          render :action => "add_show"
          return
        end
        
        @show.venue = @venue
        if !@show.save
          render :action => "add_show"
          return
        end
        
        flash[:notice] = 'Show added'
        redirect_to(:action => "shows")
      end
    end
  end
  

#  def index
#    list
#    render :action => 'list'
#  end
#
#  def list
#    @band_pages, @bands = paginate :band, :per_page => 10
#  end
#
#  def show
#    @band = Band.find(params[:id])
#  end
#
#  def new
#    @band = Band.new
#  end
#
#  def create
#    @band = Band.new(params[:band])
#    if @band.save
#      flash[:notice] = 'Band was successfully created.'
#      redirect_to :action => 'list'
#    else
#      render :action => 'new'
#    end
#  end
#
#  def edit
#    @band = Band.find(params[:id])
#  end
#
#  def update
#    @band = Band.find(params[:id])
#    if @band.update_attributes(params[:band])
#      flash[:notice] = 'Band was successfully updated.'
#      redirect_to :action => 'show', :id => @band
#    else
#      render :action => 'edit'
#    end
#  end
#
#  def destroy
#    Band.find(params[:id]).destroy
#    redirect_to :action => 'list'
#  end

  private
  def find_band
    session[:band] ||= Band.new
    @band = session[:band]
    @public_url = public_band_url
  end
  
  def save_band_profile(msg, redirect)
    @band.attributes = @params[:band]
    if @band.save
      flash[:notice] = msg
      redirect_to(:action => redirect)
    end
  end
  
end
