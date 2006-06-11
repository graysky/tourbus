require 'test/unit'
require 'rubygems'
require_gem 'actionpack'
require File.dirname(__FILE__) + "/../init"

class TestController < Class.new(ActionController::Base)
  def thing
  end
end

class OtherTestController < Class.new(ActionController::Base)
  def thing
  end
end

class MockRequest < Struct.new(:path, :subdomains, :method, :remote_ip, :protocol, :path_parameters)
end

class RequestRoutingTest < Test::Unit::TestCase
  attr_reader :rs
  def setup
    @rs = ::ActionController::Routing::RouteSet.new
    @rs.draw {|m|
       m.connect ':controller/:action/:id'
    }
    ::ActionController::Routing::NamedRoutes.clear
    @request = MockRequest.new(
      '',
      ['www'],
      :post,
      '1.2.3.4',
      'http://'
    )
  end
  
  def test_normal_routes
    assert_raise(ActionController::RoutingError) do
      @rs.recognize(@request)
    end
    
    @request.path = '/test/thing'
    assert_kind_of(TestController, @rs.recognize(@request))
  end
  
  def test_subdomain
    @rs.draw { |m| m.connect 'thing', :controller => 'test', :requirements => { :subdomain => 'www' }  }
    @request.path = '/thing'
    assert_kind_of(TestController, @rs.recognize(@request))
    @request.subdomains = ['sdkg']
    assert_raise(ActionController::RoutingError) do
      @rs.recognize(@request)
    end
  end
  
  def test_protocol
    @rs.draw { |m| m.connect 'thing', :controller => 'test', :requirements => { :protocol => /^https/ }  }
    @request.path = '/thing'
    assert_raise(ActionController::RoutingError) do
      @rs.recognize(@request)
    end
    
    @request.protocol = "https://"
    assert_kind_of(TestController, @rs.recognize(@request))
  end
  
  def test_alternate
    @rs.draw { |m| 
      m.connect 'thing', :controller => 'test', :requirements => { :remote_ip => '1.2.3.4' }  
      m.connect 'thing', :controller => 'other_test', :requirements => { :remote_ip => '1.2.3.5' }
    }
    
    @request.path = '/thing'
    assert_kind_of(TestController, @rs.recognize(@request))
    
    @request.remote_ip = '1.2.3.5'
    assert_kind_of(OtherTestController, @rs.recognize(@request))
  end
end
