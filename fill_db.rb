require 'bundler'
Bundler.require(:db)

ROOT_DIR=File.expand_path(File.dirname(__FILE__))
SOURCE_FILE = ENV["WADOKU_SOURCE"] || "WaDokuJT-Data/WaDokuNormal.tab"

require_relative 'db/config'
require_relative 'app/models/entry'

# Clear everything
DataMapper.auto_migrate!

source = open(SOURCE_FILE).read

Entry.transaction do
  source.each_line do |line|
    entry_txt = line.split("\t") 

    Entry.create(:wadoku_id => entry_txt[0], :midashigo => (entry_txt[2] == "") ? entry_txt[1] : entry_txt[2], :writing => entry_txt[1], :kana => entry_txt[3] , :definition => entry_txt[4], :relation => entry_txt[8])

  end
end
