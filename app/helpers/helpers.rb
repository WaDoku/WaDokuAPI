module HashSubtree
  def subtree(sym)
    res = []
    self.keys.each do |key|
      if key == sym
        res << {key => self[key]}
      else
        if self[key].class == Hash
          self[key].extend(HashSubtree) unless self[key].respond_to?(:subtree)
          res << self[key].subtree(sym)
        elsif self[key].class == Array
          res << self[key].map{|x| x.subtree(sym)}
        end
      end
    end
    res.flatten.compact
  end
end

class Hash
  include HashSubtree
end

class WadokuSearchAPI < Sinatra::Base
  helpers do
    @@grammar = WadokuGrammar.new
    @@text_transformer = TextTransform.new
    @@html_transformer = HTMLTransform.new

    def search params
      params[:offset] ||= 0
      WadokuSearch.search(params[:query], 30, params[:offset])
    end

    # Adds a picture to the hash if one is present
    def add_picture hash, tree
      pict = tree.subtree(:pict).first
      if pict then
        hash[:caption] = pict[:pict][:capt]
        hash[:picture] = "/svg/#{pict[:pict][:filen]}.svg"
      end
      hash
    end

    def get_entry daid, format, callback
      e = Entry.first(wadoku_id: daid)
      res = ""
      begin
        parsed = @@grammar.parse e.definition
        definition = @@html_transformer.apply parsed
        res = {
          writing: e.writing,
          midashigo: (e.midashigo.strip == "" ? e.writing : e.midashigo),
          kana: e.kana,
          furigana: e.kana[/^[^\[\s]+/],
          definition: definition
        }
        add_picture res, parsed
        res
      rescue => error
        puts "Could not parse #{e.definition}"
        puts error
        nil
      end
      json = Yajl::Encoder.encode(res)

      # This is a jsonp request
      json = callback + "(" + json + ")" if callback

      json

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
          res = {
            writing: e.writing,
            midashigo: (e.midashigo.strip == "" ? e.writing : e.midashigo),
            kana: e.kana,
            furigana: e.kana[/^[^\[\s]+/],
            definition: definition
          }
          add_picture res, parsed
          res
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
