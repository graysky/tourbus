class SignupController < ApplicationController
  layout "public"
  
  def signup_band
    if request.get?
      @band = Band.new
      return
    end
    
    @band = Band.new(params[:band])
    
    # Create the band object and send the confirmation email in a transaction
    begin
      Band.transaction(@band) do
        code = @band.create_confirmation_code
        
        # Create a url for the confirm action
        confirm_url = url_for(:action => 'confirm_band')
        confirm_url += "/" + code
        
        @band.new_password = true
        @band.band_id = Band.name_to_id(@band.name)
        public_url = public_band_url(@band)
        if @band.save
          BandMailer.deliver_notify_signup(@band, confirm_url, public_url)
          @name = @band.name
          render :action => 'signup_success'
        end
      end
    rescue Exception => ex
      flash[:notice] = "Error signing up your band: #{ex.message}"
      puts ex.backtrace.to_s
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
        if (!@band.save)
          flash.now[:error] = "Error saving confirmation status"
          @band.confirmed = false
        end
      end
    else
      # Couldn't find it
      flash.now[:error] = "I don't know what you're talking about. Are you sure you clicked the right link?"
    end
  end
  
  def signup_fan
    if request.get?
      @fan = Fan.new
      return
    end
    
    @fan = Fan.new(params[:fan])
    
    # Create the fan object and send the confirmation email in a transaction
    begin
      Fan.transaction(@band) do
        code = @fan.create_confirmation_code
        
        # Create a url for the confirm action
        confirm_url = url_for(:action => 'confirm_fan')
        confirm_url += "/" + code
        
        @fan.new_password = true
        if @fan.save
          FanMailer.deliver_notify_signup(@fan, confirm_url)
          @name = @fan.name
          render :action => 'signup_success'
        end
      end
    rescue Exception => ex
      flash[:notice] = "Error registering your account: #{ex.message}"
      puts ex.backtrace.to_s
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
