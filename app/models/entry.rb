class Entry
  include DataMapper::Resource

  property :id, Serial
  property :wadoku_id, String, :index => true
  property :writing, String
  property :kana, String
  property :definition, Text
  property :relation, String, :index => true
  property :midashigo, String
end
