require_relative 'test_helper'

class TestApp < Chopsticks::Application
end

class TestController < Chopsticks::Controller
  def index
    'Hello'
  end
end

class ChopsticksAppTest < Minitest::Test
  include Rack::Test::Methods

  def app
    TestApp.new
  end

  def test_routes
    get '/test/index'
    assert last_response.ok?
    body = last_response.body
    assert body['Hello']
  end

end
