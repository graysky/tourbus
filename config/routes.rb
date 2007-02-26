ActionController::Routing::Routes.draw do |map|
  # Add your own custom routes here.
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Metro shortcuts using subdomains
  map.connect '', :controller => 'public', :action => 'boston', :conditions => { :subdomain => 'boston' }
  map.connect '', :controller => 'public', :action => 'austin', :conditions => { :subdomain => 'austin' }
  map.connect '', :controller => 'public', :action => 'seattle', :conditions => { :subdomain => 'seattle' }
  map.connect '', :controller => 'public', :action => 'sanfran', :conditions => { :subdomain => 'sanfran' }
  map.connect '', :controller => 'public', :action => 'sanfran', :conditions => { :subdomain => 'sf' }
  map.connect '', :controller => 'public', :action => 'chicago', :conditions => { :subdomain => 'chicago' }
  map.connect '', :controller => 'public', :action => 'la', :conditions => { :subdomain => 'losangeles' }
  map.connect '', :controller => 'public', :action => 'la', :conditions => { :subdomain => 'la' }
  map.connect '', :controller => 'public', :action => 'nyc', :conditions => { :subdomain => 'nyc' }
  map.connect '', :controller => 'public', :action => 'nyc', :conditions => { :subdomain => 'newyork' }
  map.connect '', :controller => 'public', :action => 'philadelphia', :conditions => { :subdomain => 'philadelphia' }
  map.connect '', :controller => 'public', :action => 'philadelphia', :conditions => { :subdomain => 'philly' }

  # You can have the root of your site routed by hooking up '' 
  map.connect '', :controller => 'public', :action => 'front_page'
  
  # Links to predefined metros
  map.connect 'metro/:metro/', :controller => 'public', :action => 'metro'

  # Forwarding from "www.tourb.us" needs this to work correctly
  map.connect 'dispatch.fcgi', :controller => 'public', :action => 'front_page'

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Private band stuff
  map.connect 'band/:action/:id', :controller => 'band'

  # Private fan stuff
  map.connect 'fans/:action/:id', :controller => 'fan'

  # Login action
  map.connect 'login/:action/:id', :controller => 'login'
  
  # Signup action
  map.connect 'signup/:action/:id', :controller => 'signup'
  
  # Feedback
  map.connect 'feedback/:action/:id', :controller => 'feedback'
  
  # Show controller
  map.connect 'show/:id', :controller => 'show', :action => 'show'
  #map.connect 'show/:action/:id', :controller => 'show'
  # Used for RSS action
  map.connect 'show/:id/:action', :controller => 'show'
  map.connect 'shows/:action/:id', :controller => 'show'
  
  # Public fan pages
  map.connect 'fan/:fan_name/:action/:id', :controller => 'fan_public'
  
  # Photo controller
  map.connect 'photo/:action/:id', :controller => 'photo'
  
  # Venue controller
  map.connect 'venue/:id', :controller => 'venue', :action => 'show'
  # Used for RSS action
  map.connect 'venue/:id/:action', :controller => 'venue'
  map.connect 'venues/:action/:id', :controller => 'venue'
  
  # Comment controller
  map.connect 'comment/:action/:id', :controller => 'comment'
  
  # Tag controller
  map.connect 'tag/:action/:id', :controller => 'tag'
  
  # Find controller
  map.connect 'find/:action/', :controller => 'find'
  
  # Misc. public pages
  map.connect 'tour/', :controller => 'public', :action => 'tour'

  map.connect 'faq/', :controller => 'public', :action => 'faq'
  map.connect 'news/', :controller => 'public', :action => 'news'
  map.connect 'turkers/:action', :controller => 'turkers'
  
  # Admin section
  map.connect 'admin/:action/:id', :controller => 'admin'
  
  # Badge controller
  #map.connect 'badge/', :controller => 'badge', :action => 'index'
  map.connect 'badge/:action/', :controller => 'badge'
  map.connect 'badge/style/:style', :controller => 'badge', :action => 'style'
    
  # Public band pages (must be last)
  map.connect ':short_name/:action/:id', :controller => 'band_public'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'
end
