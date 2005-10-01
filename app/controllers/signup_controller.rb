class SignupController < ApplicationController
  before_filter :find_band
  layout "public"
  
  def step1
    return if request.get?
    
    @band = Band.new(params[:band])
    
    # Create the band object and send the confirmation email in a transaction
    begin
      Band.transaction(@band) do
        code = @band.create_confirmation_code
        
        # Create a url for the confirm action
        confirm_url = url_for(:action => 'confirm')
        confirm_url += "/" + code
        
        @band.new_password = true
        @band.band_id = Band.name_to_id(@band.name)
        public_url = url_for(:controller => '') + @band.band_id
        if @band.save
          BandMailer.deliver_notify_signup(@band, confirm_url, public_url)
          session[:band] = @band
          redirect_to :action => 'step2'
        end
      end
    rescue Exception => ex
      flash[:notice] = "Error signing up your band: #{ex.message}"
      puts ex.backtrace.to_s
    end
  end
  
  def step2
    # Nothing to do
  end
  
  def confirm
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
  
  private
  def find_band
    session[:band] ||= Band.new
    @band = session[:band]
  end
end
