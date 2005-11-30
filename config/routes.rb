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
  
  # Signup action
  map.connect 'signup/:action/:id', :controller => 'signup'
  
  # Show controller
  map.connect 'show/:action/:id', :controller => 'show'
  
  # Public fan pages
  map.connect 'fan/:fan_name/:action', :controller => 'fan_public'
  
  # Venue controller
  map.connect 'venue/:action/:id', :controller => 'venue'
  
  # Public band pages (must be last)
  map.connect ':band_id/:action', :controller => 'band_public'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'
end
