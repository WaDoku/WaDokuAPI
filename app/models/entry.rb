#encoding: utf-8
class Entry
  include DataMapper::Resource

  property :id, Serial
  property :wadoku_id, String, :index => true
  property :writing, String, :length => 255
  property :kana, Text, :default => ""
  property :definition, Text, :default => ""
  property :pos, String, :default => ""
  property :relation, String, :index => true, :length => 255
  property :relation_description, Text, :default => ""
  property :relation_kind, Text, :default => ""
  property :romaji_help, Text, :default => ""
  property :midashigo, Text, :default => ""
  property :definition_html, Text, :default => ""
  property :definition_plain, Text, :default => ""
  property :audio_url, Text, :default => ""
  property :picture_url, Text, :default => ""
  property :picture_caption, Text, :default => ""
  property :tres, Text, :default => ""
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
