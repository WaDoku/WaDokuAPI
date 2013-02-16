#encoding: utf-8
class Entry
  include DataMapper::Resource

  property :id, Serial
  property :wadoku_id, String, :index => true
  property :writing, String, :length => 255
  property :kana, String
  property :definition, Text
  property :pos, String
  property :relation, String, :index => true, :length => 255
  property :relation_description, String
  property :relation_kind, String
  property :romaji_help, String, :length => 255
  property :midashigo, String, :length => 255
  property :definition_html, Text
  property :definition_plain, Text
  property :audio_url, String, :length => 255
  property :picture_url, String, :length => 255
  property :picture_caption, String, :length => 255
  property :tres, Text

  has n, :lemmas

  def romaji
    kana.to_roma
  end

  def writing_kanji
    self.writing.scan(/\p{Han}+/).join(" ")
  end
end
