class WadokuSearchAPI < Sinatra::Base
  set :static, true
  set :root, ROOT_DIR
  set :logging, true

  get "/api/v1/search" do
    @res = search(params)
    make_results @res, params[:format] || "plain", params[:callback]
  end

  get "/api/v1/entry/:daid" do
    get_entry params[:daid], "html", params[:callback]
  end
end
