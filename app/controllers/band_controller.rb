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
	  # TODO check for unclaimed band
      @session[:band] = band
      redirect_back_or_default( public_band_url )
    else
      @error_message  = "Login unsuccessful. Please check your username and password, and that " +
                        "your account has been confirmed."
    end
  end

  def logout
    session[:band] = nil
    redirect_to(:controller => "public", :action => "front_page")
  end

  def settings
    return if @request.get?
    save_band_profile("Account information was successfully updated", "settings")
  end
  
  # DEPRECATED The the band homepage
  def home
    return if @request.get?
    save_band_profile("Profile information was successfully updated", "home")
  end
  
  # DEPRECATED Contact info
  def contact
    return if @request.get?
    save_band_profile("Contact information was successfully updated", "contact")
  end
  
  # DEPRECATED
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
  
  # DEPRECATED
  def shows
  end
  
  #########
  # Private
  #########
  private
  
  def find_band
    session[:band] ||= Band.new
    @band = session[:band]
    @public_url = public_band_url
  end
  
  def save_band_profile(msg, redirect)
    @band.update_attributes(params[:band])
    if @band.save
      flash[:notice] = msg
      redirect_to(:action => redirect)
    end
  end
  
end
