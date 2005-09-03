require File.dirname(__FILE__) + '/../test_helper'

class BandServicesTest < Test::Unit::TestCase
  fixtures :band_services

  def setup
    @band_services = BandServices.find(1)
  end

  # Replace this with your real tests.
  def test_truth
    assert_kind_of BandServices,  @band_services
  end
end
