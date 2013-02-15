# This class keeps single lemmata. This is because an Entry.writing field may
# contain several lemmata and we want to be able to do "exact" searches.
class Lemma
  include DataMapper::Resource

  property :id, Serial
  property :content, String

  belongs_to :entry
end
