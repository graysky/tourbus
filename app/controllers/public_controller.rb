# Shows the basic public pages of the site
class PublicController < ApplicationController
  include Geosearch
  
  helper :portlet
  before_filter :announcement, :only => :front_page
  layout "public", :except => [:beta, :beta_signup] 

  # The front page of the app
  def front_page
    # Note: this needs to match the view exactly
    bands_key = {:action => 'front_page', :part => 'popular_bands'}
    shows_key = {:action => 'front_page', :part => 'upcoming_shows'}
    
    when_not_cached(bands_key, 2.hours.from_now) do
      # Fetch and cache the list of bands
      get_popular_bands
    end
    
    when_not_cached(shows_key, 2.hours.from_now) do
      # Fetch and cache the list of shows
      get_popular_shows
    end
  end
  
  # The beta page to ask for invitation code
  def beta
    return if @request.get?
    
    # Check the form
    invite_code = params['code']
    
    # This needs to match what application has
    secret = "backstage"
    
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
  
  # Form to sign up for the beta
  def beta_signup
    return if @request.get?  
  
    email_addr = params['email']
    
    # Send us mail about the signup
    BetaMailer.deliver_signup(email_addr)
  end
  
  # The News page
  def news
    # TODO Need to paginate
    @announcements = Announcement.find(:all, :order => "created_at DESC")
  end
  
  # The FAQ page
  def faq
  end
  
  private
  
  def page_size
    10
  end
    
  def get_popular_shows
    # Get the 10 most popular shows, then sort by date
    options = default_search_options
    options[:sort] = popularity_sort_field
    
    @shows, count = Show.ferret_search_date_location('*', nil, nil, nil, nil, options)
    @shows.sort! { |x,y| x.date <=> y.date }
  end 
  
  def get_popular_bands
    # The 10 most popular bands
    options = default_search_options
    options[:sort] = popularity_sort_field
    
    @bands, count = Band.ferret_search_date_location('*', nil, nil, nil, nil, options)
  end  
end