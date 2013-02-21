#encoding: utf-8
class Entry
  include DataMapper::Resource

  property :id, Serial
  property :wadoku_id, String, :index => true
  property :writing, String, :length => 255
  property :kana, Text
  property :definition, Text, :default => ""
  property :pos, String
  property :relation, String, :index => true, :length => 255
  property :relation_description, Text
  property :relation_kind, Text
  property :romaji_help, Text
  property :midashigo, Text
  property :definition_html, Text
  property :definition_plain, Text
  property :audio_url, Text
  property :picture_url, Text
  property :picture_caption, Text
  property :tres, Text
  property :updated_at, DateTime

  has n, :lemmas

  def romaji
    kana.to_roma
  end

  def writing_kanji
    self.writing.scan(/\p{Han}+/).join(" ")
  end

  def generate_tres! parsetree
    return unless parsetree
    @@tre_filter ||= TreFilter.new

    self.tres = @@tre_filter.apply parsetree

    self.save
  end

  before :save do
    self.updated_at = DateTime.now
  end

  is :versioned, :on => :updated_at

end
