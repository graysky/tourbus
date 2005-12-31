require 'cgi'
require_dependency "geocoder"

class BandController < ApplicationController
  include BandLoginSystem
  
  before_filter :band_login_required, :except => [:login, :lookup_band_for_show, :add_selected_band]
  before_filter :find_band, :except => [:lookup_band_for_show, :add_selected_band]
  session :off, :only => %w(lookup_band_for_show add_selected_band)
  
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

  def lookup_band_for_show
    #puts "Lookup band name: " + params[:name]
    
    name = params[:name].strip
    if params[:name] && name != ""
      bands = Band.ferret_search(name + "*", :num_docs => 5)
    else
      bands = []
    end
    
    render :partial => "band_search_preview", :locals => { :bands => bands}
  end

  def add_selected_band
    #p params
    id = params[:id]
    if id.nil? or id == "" or id == "null"
      # Are adding a new band with the given name. Make sure it's not a duplicate...
      name = CGI.unescape(params[:name])
      band_id = Band.name_to_id(name)
      if Band.find_by_band_id(band_id)
        msg = "We found a band with that name in the system."
        msg << "Please search again for this band name and click the result to add the band to the show."
        msg << "If you need to add a new band with the same name, please add the location of the band "
        msg << " in parenthese after the name (like \"Berzerker (Boston, MA)\"."
        render :text => msg, :status => 500
        return
      end
      
      band = Band.new
      band.name = name + " <small>(new!)</small>"
    else
      band = Band.find(params[:id])
    end
    
    render :partial => "shared/band_playing", :object => band
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
