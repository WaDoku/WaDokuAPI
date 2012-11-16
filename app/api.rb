get "/api/v1/search" do
  results = @wadoku_search.search params[:query],
                                  params[:ids] || 20,
                                  params[:offset] || 0
  return results.to_json 
end

get "/api/v1/entry/:id" do 

end
