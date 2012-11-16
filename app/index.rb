class WadokuSearchAPI < Sinatra::Base

  get "/api/v1/search" do
    @res = search(params)
    make_results @res.ids
  end
end
