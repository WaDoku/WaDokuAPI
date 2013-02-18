require 'spec_helper'

describe WadokuSearch do

  describe "sorting" do
    it 'should favor hits in tres' do
      entries = [
        Entry.get(112), # 相… [1]
        Entry.get(631), # 青
        Entry.get(9999) # 日本 [a]; ニッポン
      ]
      Picky::Indexes.each do |index|
        index.clear
        entries.each do |entry|
          index.replace entry
        end
      end
      res = WadokuSearch.search("japan", 30, 0)
      res.ids[0].should == 9999
    end
  end

end

describe Entry do
  it 'should generate tres' do
  end
end
