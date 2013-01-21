class WadokuSearchAPI < Sinatra::Base
  helpers do
    @@grammar = WadokuGrammar.new
    @@text_transformer = TextTransform.new
    @@html_transformer = HTMLTransform.new

    def search params
      params[:offset] ||= 0
      WadokuSearch.search(params[:query], 30, params[:offset])
    end

    def make_results search, format = "plain"
      ids = search.ids
      @entries = Entry.all(wadoku_id: ids)

      case format
      when "plain"
        transformer = @@text_transformer
      when "html"
        transformer = @@html_transformer
      else
        return Yajl::Encoder.encode({error: "Wrong format"})
      end

      results = @entries.map do |e|
        begin
          parsed = @@grammar.parse e.definition
          definition = transformer.apply parsed
          {
            writing: e.writing,
            midashigo: e.midashigo,
            kana: e.kana,
            definition: definition
          }
        rescue => e
          nil
        end
      end

      res = {
        total: search.total,
        query: search.query,
        offset: search.offset,
        entries: results.compact
      }

      Yajl::Encoder.encode(res)
    end
  end
end
