class WadokuSearchAPI < Sinatra::Base
  set :static, true
  set :root, ROOT_DIR
  set :logging, true

  get "/api/v1/search" do
    @res = search(params)
    options = Hash[params.map{|k,v|[k.to_sym, v]}] # Symbolize all options
    make_results @res, options
  end

  get "/api/v1/entry/:daid" do
    @entry = Entry.first(wadoku_id: params[:daid])
    JsonEntry.new(@entry).to_json(params)
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
end
