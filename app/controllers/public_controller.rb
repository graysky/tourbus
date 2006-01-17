# Shows the basic public pages of the site
class PublicController < ApplicationController
  
  #helper :porlet

  # The front page of the app
  def front_page
    
    get_popular_bands()
    
  end
  
  # The About Us page
  def about_us
  
  end
  
  # The FAQ page
  def faq
  
  end
  
  private
  
  def get_popular_bands
  
    # Get the 10 most popular bands
    @bands = Band.find(:all,
                       :order => "page_views DESC",
                       :limit => 10
                      ) 
  end  
  
  
end
