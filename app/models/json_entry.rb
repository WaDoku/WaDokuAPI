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

    parsed = nil
    begin
      if format == "html" && @entry.definition_html
        definition = @entry.definition_html
      elsif format == "plain" && @entry.definition_plain
        definition = @entry.definition_plain
      else
        parsed = @@grammar.parse @entry.definition
        definition = transformer.apply parsed
      end

      res = {
        writing: @entry.writing,
        midashigo: (@entry.midashigo.strip == "" ? @entry.writing : @entry.midashigo),
        kana: @entry.kana,
        furigana: @entry.kana[/^[^\[\s]+/],
        definition: definition,
        sub_entries: sub_entries
      }
      add_picture res, parsed
      add_audio res, parsed
      return res
    rescue Parslet::ParseFailed => reason
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

  def sub_entries
    hash = (Entry.all(:relation => @entry.writing) + Entry.all(:relation => "HE\v#{@entry.writing}")).map{|e| [e.wadoku_id, e.relation_description]}.group_by{|e| e[1]}
    hash.keys.each do |key|
      hash[key] = hash[key].map(&:first).flatten
    end
    hash
  end

  def error reason
    {error: reason}
  end

  # Adds a picture to the hash iff one is present
  def add_picture hash, tree
    if @entry.picture_url
      hash[:caption] = @entry.picture_caption
      hash[:picture] = @entry.picture_url
    elsif tree
      pict = tree.subtree(:pict).first
      if pict then
        hash[:caption] = pict[:pict][:capt]
        hash[:picture] = "/svg/#{pict[:pict][:filen]}.svg"
      end
    end
    hash
  end

  # Adds an audio link to the hash iff one is present
  def add_audio hash, tree
    if @entry.audio_url
      hash[:audio] = @entry.audio_url
    elsif tree
      audio = tree.subtree(:audio).first
      if audio then
          hash[:audio] = "/audio/#{audio[:audio][:text]}.mp3"
      end
    end
    hash
  end
end
