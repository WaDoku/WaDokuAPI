class WadokuSearchAPI < Sinatra::Base

  get "/api/v1/search" do
    @res = WadokuSearch.search(params[:query]).ids
    @res.to_json
  end
end
