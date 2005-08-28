class SignupController < ApplicationController
  before_filter :find_band
  layout "public"
  
  def step1
 
  end
  
  def step2
    puts @band.name
  end
  
  def signup
    @band = Band.new(params[:band])
    puts @band.name
    if @band.save
      session[:band] = @band
      redirect_to :action => 'step2'
    else
      render :action => 'step1'
    end
  end
  
  private
  def find_band
    session[:band] ||= Band.new
    @band = session[:band]
  end
end
