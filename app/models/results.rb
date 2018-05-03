class Results

  def initialize query, options = {}
    defaults = {
      'mode' => 'fuzzy',
      'offset' => 0,
      'limit' => 30,
      'format'=> 'html'
    }
    @options = defaults.merge(options)
    @options['query'] = query

    get_entries!
  end

  def to_hash
    results = @entries.map{|entry| JsonEntry.new(entry).to_hash(@options)}

    # Don't give out errored entries.
    #results = results.reject {|entry| entry[:error]}

    res = {
      total: @total,
      query: @options['query'],
      limit: @options['limit'],
      offset: @options['offset'],
      mode: @options['mode'],
      entries: results
    }
    res
  end

  def to_json
    json = Yajl::Encoder.encode self.to_hash
    json = "#{@options['callback']}(#{json})" if @options['callback']
    json
  end

  # Fills @entries and @total
  def get_entries!
    case @options['mode']
    when 'fuzzy'
      search = WadokuSearch.search(@options['query'], @options['limit'], @options['offset'])
      @total = search.ids.uniq.size
      @entries = Entry.all(id: search.ids)
    when 'forward'
      @entries = Lemma.all(:content.like => @options['query'] + "%").map(&:entry)
      @total = @entries.count
      @entries = @entries[(@options['offset'].to_i)...(@options['offset'] + @options['limit'])]
    when 'backward'
      @entries = Lemma.all(:content.like => "%" + @options['query']).map(&:entry)
      @total = @entries.count
      @entries = @entries[(@options['offset'].to_i)...(@options['offset'] + @options['limit'])]
    end
  end
end
