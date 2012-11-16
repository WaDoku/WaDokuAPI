class WadokuSearchAPI < Sinatra::Base
  helpers do
    @@grammar = WadokuGrammar.new
    @@text_transformer = TextTransform.new

    def search params
      WadokuSearch.search(params[:query])
    end

    def make_results ids, format = :json
      @entries = Entry.all(wadoku_id: ids)
      case format
      when :json
        @results = @entries.map do |e|
          parsed = @@grammar.parse e.definition
          definition = @@text_transformer.apply parsed
          {
            midashigo: e.midashigo,
            definition: definition
          }
        end.to_json
      end
      @results
    end
  end
end
