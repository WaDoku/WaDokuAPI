class WadokuSearchAPI < Sinatra::Base

  get "/api/v1/search" do
    @res = WadokuSearch.search(params[:query]).ids
    @entries = Entry.all(wadoku_id: @res)
    @entries.map do |e|
      parsed = WadokuGrammar.new.parse(e.definition)
      {
        midashi: e.midashigo,
        definition: TextTransform.new.apply(parsed)
      }
    end.to_json
  end
end
