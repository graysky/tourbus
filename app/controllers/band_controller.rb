require 'cgi'
require_dependency "geocoder"

# Band private controller for settings
class BandController < ApplicationController
  include BandLoginSystem
  
  before_filter :band_login_required, :except => [:lookup_band_for_show, :add_selected_band, :logout]
  before_filter :find_band, :except => [:lookup_band_for_show, :add_selected_band]
  session :off, :only => %w(lookup_band_for_show add_selected_band)
  
  layout "public"
  
  def index
  end
  
  def lookup_band_for_show
    name = params[:name].strip
    if params[:name] && name != ""
      short_name = Band.name_to_id(name)
      
      if short_name.length < 3 || short_name == 'the'
        bands = []
      else
        options = { :conditions => ["sort_name:#{short_name}*"], :num_docs => 5 }
        bands, count = Band.ferret_search(nil, options)
      end
    else
      bands = []
    end
    
    render :partial => "band_search_preview", :locals => { :bands => bands}
  end

  def add_selected_band
    id = params[:id]
    if id.nil? or id == "" or id == "null"
    
      # Are adding a new band with the given name. Make sure it's not a duplicate...
      name = CGI.unescape(params[:name])
      short_name = Band.name_to_id(name)
      if Band.find_by_short_name(short_name)
        logger.info "Asked to add existing band to show as new: #{name}"
        msg = "We found a band with that name in the system."
        msg << "Please search again for this band name and click the result to add the band to the show."
        msg << "If you need to add a new band with the same name as an existing band, please add the location of the band "
        msg << " in parentheses after the name (like \"Berzerker (Boston, MA)\"."
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
    logger.info "Band #{@band.name} logged out"
    session[:band_id] = nil
    cookies.delete :login
    redirect_to(:controller => "public", :action => "front_page")
  end

  def settings
    return if @request.get?
    save_band_profile("Account information was successfully updated", "settings")
  end

  def map_tool
    # Nothing to do
  end

  def change_password
    if request.get?
      @band.password = @band.password_confirmation = FAKE_PASSWORD
      return
    end
    
    
    @band.update_attributes(params[:band])
    if @band.password == FAKE_PASSWORD and @band.password_confirmation == FAKE_PASSWORD
      flash[:error] = "You must enter a new password"
    else
      begin
        @band.new_password = true
        if @band.save
          flash[:success] = "Password changed"
          redirect_to :action => 'settings'
        end
      ensure
        @band.password = @band.password_confirmation = ''
      end
    end
  end

  #########
  # Private
  #########
  private
  
  def find_band
    band = logged_in_band
    band ||= Band.new
    @band = band
    @public_url = public_band_url
  end
  
  def save_band_profile(msg, redirect)
  
    begin
      @band.update_attributes(params[:band])
      if @band.save
        flash[:success] = msg
        redirect_to(:action => redirect)
      end
    rescue Exception => e
      logger.error "Error saving band profile for #{@band.name}, #{e.to_s}"
      flash[:error] = e.to_s
    end
  end
  
end
