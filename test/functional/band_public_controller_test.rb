require File.dirname(__FILE__) + '/../test_helper'
require 'band_public_controller'

# Re-raise errors caught by the controller.
class BandPublicController; def rescue_action(e) raise e end; end

class BandPublicControllerTest < Test::Unit::TestCase
  def setup
    @controller = BandPublicController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
