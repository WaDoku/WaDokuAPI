class WadokuTabReader

  def initialize(path)
    @path = path
  end

  def each(&block)
  
    file = open(@path)
    file.lines.each do |line|
      block.call(WadokuEntry.new(line.split("\t")))
    end
    
  end

  class WadokuEntry
    def initialize(arr)
      @arr = arr
    end

    def id
      @arr[0]
    end
  
    def writing
      @arr[1]
    end
  
    def kana
      @arr[2]
    end

    def romaji
      kana.to_roma
    end

    def definition
      @arr[3]
    end
  end
end
