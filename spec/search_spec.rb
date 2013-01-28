require 'spec_helper'

describe WadokuSearchAPI do

  def app
    @app ||= WadokuSearchAPI
  end

  it 'should answer something' do
    get '/api/v1/search?query=japan'
    last_response.should be_ok
  end

end
