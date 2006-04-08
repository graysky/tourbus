# Shows the basic public pages of the site
class PublicController < ApplicationController
  
  helper :portlet
  before_filter :announcement, :only => :front_page
  layout "public", :except => [:beta] 
  
  # The front page of the app
  def front_page
    
    # Note: this needs to match the view exactly
    bands_key = {:action => 'front_page', :part => 'popular_bands'}
    shows_key = {:action => 'front_page', :part => 'upcoming_shows'}
    
    when_not_cached(bands_key, 6.hours.from_now) do
      # Fetch and cache the list of bands
      get_popular_bands
    end
    
    when_not_cached(shows_key, 6.hours.from_now) do
      # Fetch and cache the list of shows
      get_popular_shows
    end
  end
  
  # The beta page to ask for invitation code
  def beta
    if @request.get?
      #render :layout => "landing"
      return
    end
    
    # Check the form
    invite_code = params['code']
    
    # This needs to match what application has
    secret = "rock"
    
    # Check to see if they should be allowed in
    if invite_code == secret
      # Let them in and remember they got in!
      cookies[:invite] = { :value => secret, :expires => Time.now + 6.months }
    
      # Redirect to front page
      redirect_to("/")
    else
      flash.now[:error] = "Invalid invitation code -- please try again"
      
    end
    
  end
  
  # The News page
  def news
    # TODO Need to paginate
    @announcements = Announcement.find(:all, :order => "created_at DESC")
  end
  
  # The About Us page
  def about_us
  end
  
  # The FAQ page
  def faq
  end
  
  private
    
  def get_popular_shows
    # Get the 10 most popular shows
    @shows = Show.find(:all,
                       :conditions => ["date > ?", Time.now - 1.days],
                       :order => "num_watchers DESC",
                       :limit => 10
                      ) 
  end 
  
  def get_popular_bands  
    # Get the 10 most popular bands
    @bands = Band.find(:all,
                       :order => "page_views DESC",
                       :limit => 10
                      ) 
  end  
end