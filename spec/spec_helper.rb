ENV['RACK_ENV'] = "test"
Bundler.require(:test)
require File.expand_path(File.dirname(__FILE__) + "/../app")

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
end
