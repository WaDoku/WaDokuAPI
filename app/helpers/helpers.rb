class WadokuSearchAPI < Sinatra::Base
  helpers do
    @@grammar = WadokuGrammar.new
    @@text_transformer = TextTransform.new
    @@html_transformer = HTMLTransform.new

    def search params
      params[:offset] ||= 0
      WadokuSearch.search(params[:query], 30, params[:offset])
    end

    def make_results search, format = "json"
      ids = search.ids
      @entries = Entry.all(wadoku_id: ids)

      case format
      when "json"
        results = @entries.map do |e|
          parsed = @@grammar.parse e.definition
          definition = @@text_transformer.apply parsed
          {
            midashigo: e.midashigo,
            definition: definition
          }
        end
      when "html"
        results = @entries.map do |e|
          parsed = @@grammar.parse e.definition
          definition = @@html_transformer.apply parsed
          {
            midashigo: e.midashigo,
            definition: definition
          }
        end
      else 
        return Yajl::Encoder.encode({error: "Wrong format"})
      end

      res = {
        total: search.total,
        query: search.query,
        offset: search.offset,
        entries: results
      }

      Yajl::Encoder.encode(res)
    end
  end
end
