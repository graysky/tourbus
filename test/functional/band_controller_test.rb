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

  def test_create
    num_bands = Band.count

    post :create, :band => {"name" => "xxx", "contact_email" => "sf@df.com", 
                            "band_id" => "xxx", "zipcode" => "01721"}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_bands + 1, Band.count
  end

end
