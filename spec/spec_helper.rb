ENV['RACK_ENV'] = "test"
Bundler.require(:test)
require File.expand_path(File.dirname(__FILE__) + "/../app")

RSpec.configure do |conf|
  conf.include Rack::Test::Methods

  conf.before(:suite) do
    DatabaseCleaner.strategy = :transaction
  end

  conf.before(:each) do
    DatabaseCleaner.start
  end

  conf.after(:each) do
    DatabaseCleaner.clean
  end
end

def sign_request params, user
  params = params.dup
  params[:client_id] = user.client_id
  text = params.sort.join
  signature = Base64.encode64(OpenSSL::HMAC.digest('sha1', user.client_secret, text))
  params[:signature] = signature
  params
end
