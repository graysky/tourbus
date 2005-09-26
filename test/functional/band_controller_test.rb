require File.dirname(__FILE__) + '/../test_helper'
require 'band_controller'

# Re-raise errors caught by the controller.
class BandController; def rescue_action(e) raise e end; end

class BandControllerTest < Test::Unit::TestCase
  fixtures :bands

  def setup
    @controller = BandController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

end
