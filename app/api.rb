require 'openssl'
require 'base64'

class WadokuSearchAPI < Sinatra::Base
  set :static, true
  set :root, ROOT_DIR
  set :logging, true

  get "/api/v1/search" do
    res = Results.new(params.delete("query"), params).to_json
    res
  end

  get '/api/v1/suggestions' do
    suggestions = Lemma.all(:content.like => params[:query] + "%").map(&:content).uniq
    res = Yajl::Encoder.encode suggestions: suggestions
    res = "#{params[:callback]}(#{res});" if params[:callback]
    res
  end

  get "/api/v1/entry/:daid" do
    @entry = Entry.first(wadoku_id: params[:daid])
    JsonEntry.new(@entry).to_json(params)
  end

  post '/api/v1/entry' do
    authenticate_request!
    params.delete("client_id")
    params.delete("signature")
    @entry = Entry.new(params)
    if @entry.save
      Yajl::Encoder.encode({entry: JsonEntry.new(@entry)})
    else
      Yajl::Encoder.encode({error: "Could not create entry."})
    end
  end

  get "/api/v1/picky" do
    params[:offset] ||= 0
    params[:ids] ||= 30
    results = WadokuSearch.search(params[:query], params[:ids], params[:offset])
    res = results.to_json
    res = "#{params[:callback]}(#{res});" if params[:callback]
    res
  end

  get '/api/v1/parse' do
    @@grammar ||= WadokuGrammar.new
    markup = params[:markup]
    begin
      parse = @@grammar.parse markup
      Yajl::Encoder.encode parse
    rescue Parslet::ParseFailed => e
      Yajl::Encoder.encode({error: e})
    end
  end

  # A test route that just checks if your request was authenticated
  get '/api/v1/check_authentication' do
    authenticate_request!
    "You successfully authenticated!"
  end

  def authenticate_request!
    signature = params.delete('signature')
    client = User.first(:client_id => params['client_id'])
    unless client
      status 403
      return "Could not authenticate!"
    end

    text = params.sort.join()
    valid_signature = Base64.encode64(OpenSSL::HMAC.digest('sha1', client.client_secret, text))

    unless signature == valid_signature
      status 403
      return "Could not authenticate!"
    end
  end
end
