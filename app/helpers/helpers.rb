class WadokuSearchAPI < Sinatra::Base
  helpers do
    def search params
      params[:offset] ||= 0
      WadokuSearch.search(params[:query], 30, params[:offset])
    end

    def make_results search, format, callback
      ids = search.ids
      @entries = Entry.all(id: ids)

      results = @entries.map{|entry| JsonEntry.new(entry).to_hash({format: format, callback: callback})}

      # Don't give out errored entries.
      results = results.reject {|entry| entry[:error]}

      res = {
        total: search.total,
        query: search.query,
        offset: search.offset,
        entries: results
      }

      json = Yajl::Encoder.encode(res)

      # This is a jsonp request
      json = callback + "(" + json + ")" if callback

      json
    end
  end
end
