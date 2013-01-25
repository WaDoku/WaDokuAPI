class WadokuSearchAPI < Sinatra::Base
  helpers do
    @@grammar = WadokuGrammar.new
    @@text_transformer = TextTransform.new
    @@html_transformer = HTMLTransform.new

    def search params
      params[:offset] ||= 0
      WadokuSearch.search(params[:query], 30, params[:offset])
    end

    def make_results search, format, callback
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
            midashigo: (e.midashigo.strip == "" ? e.writing : e.midashigo),
            kana: e.kana,
            definition: definition
          }
        rescue => error
          puts "Could not parse #{e.definition}"
          puts error
          nil
        end
      end

      res = {
        total: search.total,
        query: search.query,
        offset: search.offset,
        entries: results.compact
      }

      json = Yajl::Encoder.encode(res)

      # This is a jsonp request
      json = callback + "(" + json + ")" if callback

      json
    end
  end
end
