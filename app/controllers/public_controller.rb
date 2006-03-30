# Shows the basic public pages of the site
class PublicController < ApplicationController
  
  helper :portlet
  before_filter :announcement, :only => :front_page
  
  # The front page of the app
  def front_page
    
    get_popular_bands
    
    get_popular_shows
  end
  
  # The beta page to ask for invitation code
  def beta
    return if @request.get?
    
    # Check the form
    invite_code = params['code']
    
    # This needs to match what application has
    secret = "3gnm"
    
    # Check to see if they should be allowed in
    if invite_code == secret
      # Let them in and remember they got in!
      cookies[:invite] = { :value => secret, :expires => Time.now + 6.months }
    
      # Redirect to front page
      redirect_to("/")
    else
      flash.now[:error] = "Invalid invitation code"
      
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
                       :order => "num_watchers DESC",
                       :limit => 10
                      ) 
  end 
  
  # TODO Change to use index and cache this
  def get_popular_bands
  
    # Get the 10 most popular bands
    @bands = Band.find(:all,
                       :order => "page_views DESC",
                       :limit => 10
                      ) 
  end  
  
  
end
