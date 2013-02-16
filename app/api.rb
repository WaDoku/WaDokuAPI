class WadokuSearchAPI < Sinatra::Base
  set :static, true
  set :root, ROOT_DIR
  set :logging, true

  get "/api/v1/search" do
    res = Results.new(params.delete("query"), params).to_json
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
