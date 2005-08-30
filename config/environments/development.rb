require 'active_support/whiny_nil'

Dependencies.mechanism                             = :load
ActionController::Base.consider_all_requests_local = true
ActionController::Base.perform_caching             = false
ActionMailer::Base.delivery_method                 = :smtp
BREAKPOINT_SERVER_PORT = 42531