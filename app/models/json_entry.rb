class JsonEntry
  def initialize entry
    @@grammar ||= WadokuGrammar.new
    @@text_transformer ||= TextTransform.new
    @@html_transformer ||= HTMLTransform.new
    @entry = entry
  end

  def to_hash options = {}
    format = options[:format] || "html"

    case format
      when 'html' then transformer = @@html_transformer
      when 'plain' then transformer = @@text_transformer
    end

    return error("Invalid WaDoku id.") unless @entry

    begin
      parsed = @@grammar.parse @entry.definition
      definition = transformer.apply parsed
      res = {
        writing: @entry.writing,
        midashigo: (@entry.midashigo.strip == "" ? @entry.writing : @entry.midashigo),
        kana: @entry.kana,
        furigana: @entry.kana[/^[^\[\s]+/],
        definition: definition
      }
      add_picture res, parsed
      add_audio res, parsed
      return res
    rescue => reason
      return error(reason)
    end
  end

  def to_json options = {}
    format = options[:format] || "html"
    callback = options[:callback] || nil

    res = to_hash options

    json = Yajl::Encoder.encode res

    # This is a jsonp request
    json = callback + "(" + json + ")" if callback
    return json
  end

  private

  def error reason
    {error: reason}
  end

  # Adds a picture to the hash iff one is present
  def add_picture hash, tree
    pict = tree.subtree(:pict).first
    if pict then
      hash[:caption] = pict[:pict][:capt]
      hash[:picture] = "/svg/#{pict[:pict][:filen]}.svg"
    end
    hash
  end

  # Adds an audio link to the hash iff one is present
  def add_audio hash, tree
    audio = tree.subtree(:audio).first
    if audio then
        hash[:audio] = "/audio/#{audio[:audio][:text]}.mp3"
    end
  end
end
