ActionController::Routing::Routes.draw do |map|
  # Add your own custom routes here.
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Here's a sample route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  # map.connect '', :controller => "welcome"
  map.connect '', :controller => 'public', :action => 'front_page'

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
  
  # Show controller (TODO Sort this out)
  map.connect 'show/:id', :controller => 'show', :action => 'show'
  map.connect 'shows/:action/:id', :controller => 'show'
  
  # Public fan pages
  map.connect 'fan/:fan_name/:action/:id', :controller => 'fan_public'
  
  # Photo controller
  map.connect 'photo/:action/:id', :controller => 'photo'
  
  # Venue controller
  map.connect 'venue/:id', :controller => 'venue', :action => 'show'
  map.connect 'venue/:action/:id', :controller => 'venue'
  
  # Comment controller
  map.connect 'comment/:action/:id', :controller => 'comment'
  
  # Tag controller
  map.connect 'tag/:action/:id', :controller => 'tag'
  
  # Find controller
  map.connect 'find/:action/:id', :controller => 'find'
  
  # Public band pages (must be last)
  map.connect ':band_id/:action/:id', :controller => 'band_public'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'
end
