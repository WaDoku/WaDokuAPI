class WadokuSearchAPI < Sinatra::Base
  set :static, true
  set :root, ROOT_DIR
  set :logging, true

  get "/api/v1/search" do
    @res = search(params)
    make_results @res, params[:format] || "html", params[:callback]
  end

  get "/api/v1/entry/:daid" do
    @entry = Entry.first(wadoku_id: params[:daid])
    JsonEntry.new(@entry).to_json(params)
  end
end
