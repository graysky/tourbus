require 'uuidtools'

# Controls registering both fans and bands
class SignupController < ApplicationController
  layout "public"
  
  # Initial action when they have chosen one or the other yet
  def index
    # Nothing to do
  end
  
  # Register a band
  def band
    if request.get?
      @band = Band.new
      return
    end
    
    # Create the band object and send the confirmation email in a transaction
    begin
      @band = Band.new(params[:band])
      Band.transaction(@band) do
        code = @band.create_confirmation_code
        
        # Create a url for the confirm action
        confirm_url = url_for(:action => 'confirm_band')
        confirm_url += "/" + code
        
        @band.new_password = true
        @band.claimed = true
        @band.uuid = UUID.random_create.to_s
        public_url = public_band_url(@band)
        if @band.save
        
          # Generate an upload email address
          @band.upload_addr = @band.create_upload_addr
          @band.upload_addr.address = UploadAddr.generate_address
          @band.upload_addr.save!
          
          logger.info("Signing up a new band: #{@band}, #{@band.name}")
          BandMailer.deliver_notify_signup(@band, confirm_url, public_url)
          @name = @band.name
          render :action => 'band_signup_success'
        end
      end
    rescue Exception => ex
      @band = Band.new if @band.nil?
      flash.now[:error] = "Error signing up your band: #{ex.message}"
    end
  end
  
  def signup_success
    # Nothing to do
  end
  
  def confirm_band
    @band = Band.find_by_confirmation_code(params[:id])
    if (@band)
      if (@band.confirmed?)
        # Someone has already confirmed this band
        @band = nil
        flash.now[:error] = "This account has already been confirmed."
      else
        # It's now confirmed
        @band.confirmed = true
        #BandMailer.deliver_gm_of_new_band(@band)
        if (!@band.save)
          flash.now[:error] = "Error saving confirmation status"
          @band.confirmed = false
        end
        
        @band.ferret_save
      end
    else
      # Couldn't find it
      flash.now[:error] = "I don't know what you're talking about. Are you sure you clicked the right link?"
    end
  end
  
  # Register a fan
  def fan
    if request.get?
      @fan = Fan.new
      return
    end
    
    # Create the fan object and send the confirmation email in a transaction
    begin
      @fan = Fan.new(params[:fan])
      Fan.transaction(@fan) do
        # Verify an address is present
        begin 
          zip = Address.parse_city_state_zip(params[:fan][:city_state_zip])
          #puts "Zipcode is: #{zip}"
          raise "Please enter a valid address within the U.S." if zip.nil? || zip == ""
        rescue Exception => exc
          # Could not validate their address
          raise "Please enter a valid address within the U.S."
        end
      
        code = @fan.create_confirmation_code
        
        # Create a url for the confirm action
        confirm_url = url_for(:action => 'confirm_fan')
        confirm_url += "/" + code
        
        @fan.new_password = true
        @fan.uuid = UUID.random_create.to_s
        @fan.confirmed = true
        @fan.last_login = Time.now
        if @fan.save
        
          # Generate an upload email address
          @fan.upload_addr = @fan.create_upload_addr
          @fan.upload_addr.address = UploadAddr.generate_address
          @fan.upload_addr.save!
          logger.info("Signing up a new fan: #{@fan}, #{@fan.name}")
          FanMailer.deliver_notify_signup(@fan, confirm_url)
          
          @name = @fan.name
          flash[:new_user] = true
          @session[:first_login] = true
          @session[:fan_id] = @fan.id
      
          cookies[:type] = { :value => 'fan', :expires => Time.now + 5.years }
          cookies[:login] = { :value => @fan.uuid, :expires => Time.now + 2.weeks }
      
          set_location_defaults(@fan.location, @fan.default_radius, 'false', 'true', 'true', 'false')
          
          redirect_to :controller => "fans", :action => 'import_favorites'
        end
      end
    rescue Exception => ex
      @fan = Fan.new if @fan.nil?
      flash.now[:error] = "Error registering your account: #{ex.message}"
      logger.error(ex)
    end
  end
  
  def confirm_fan
    @fan = Fan.find_by_confirmation_code(params[:id])
    if (@fan)
      if (@fan.confirmed?)
        # Someone has already confirmed this band
        @fan = nil
        flash.now[:error] = "This account has already been confirmed."
      else
        # It's now confirmed
        @fan.confirmed = true
        #FanMailer.deliver_gm_of_new_fan(@fan)
        if (!@fan.save)
          flash.now[:error] = "Error saving confirmation status"
          @fan.confirmed = false
        end
      end
    else
      # Couldn't find it
      flash.now[:error] = "I don't know what you're talking about. Are you sure you clicked the right link?"
    end
  end
end
