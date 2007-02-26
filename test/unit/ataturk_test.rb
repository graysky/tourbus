require File.dirname(__FILE__) + '/../test_helper'

class AtaturkTest < Test::Unit::TestCase
  fixtures :turk_hit_submissions, :turk_sites, :venues
  
  class TurkHitSubmission < ActiveRecord::Base
    @@params = "sdf"
    def self.set_params(p)
      @@params = p
    end
    
    def params
      @@params
    end
    
    def params=(p)
      
    end
    
    def turk_site
      TurkSite.find(1)
    end
  end
  
  
  def setup
  
  end
  
  def test_process_hits
    TurkHitSubmission.set_params("xxx")
    
  end

end