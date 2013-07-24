require 'spec_helper'
require 'rack/test'
require 'whether'

set :environment, :test

describe Whether::App do
  include Rack::Test::Methods

  def app
    Whether::App
  end

  it "works" do
    get '/'
    last_response.should be_ok
    last_response.body.should include 'The Weather in Hong Kong'
  end
end