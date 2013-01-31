class Entry
  include DataMapper::Resource

  property :id, Serial
  property :wadoku_id, String, :index => true
  property :writing, String
  property :kana, String
  property :definition, Text
  property :pos, String
  property :relation, String, :index => true
  property :relation_description, String
  property :relation_kind, String
  property :romaji_help, String
  property :midashigo, String

  def romaji
    kana.to_roma
  end

  def tres
    self.definition.scan(/<TrE:([^>]+)>/).flatten.map(&:strip).join(" ")
  end
end
