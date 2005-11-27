class FanController < ApplicationController
 include FanLoginSystem
  
  before_filter :login_required, :except => [:login]
  before_filter :find_fan
  layout "public"
  
  def index
  end
  
  def login
    return if @request.get?
    
    if fan = Fan.authenticate(params['login'], params['password'])
      @session[:fan] = fan
      redirect_back_or_default(url_for :action => "settings")
    else
      @error_message  = "Login unsuccessful. Please check your username and password, and that " +
                        "your account has been confirmed."
    end
  end

  def logout
    session[:fan] = nil
    redirect_to(:controller => "public", :action => "front_page")
  end
  
  def settings
     return if @request.get?
     
    @fan.update_attributes(params[:fan])
    if @fan.save
      flash[:notice] = "Settings updated"
    else
      # TODO GOTO ERROR
      flash[:notice] = "error"
    end
    
  end
  
  #########
  # Private
  #########
  private
  
  def find_fan
    session[:fan] ||= Fan.new
    @fan = session[:fan]
  end
end
