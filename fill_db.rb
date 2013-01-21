require 'bundler'
Bundler.require(:db)

ROOT_DIR=File.expand_path(File.dirname(__FILE__))
SOURCE_FILE = ENV["WADOKU_SOURCE"] || "WaDokuJT-Data/WaDokuDa.tab"

require_relative 'db/config'
require_relative 'app/models/entry'

# Clear everything
DataMapper.auto_migrate!

source = open(SOURCE_FILE).read

Entry.transaction do
  source.each_line do |line|
    entry_txt = line.split("\t") 

    Entry.create(:wadoku_id => entry_txt[0],
                 :writing => entry_txt[1], 
                 :kana => entry_txt[2] , 
                 :definition => entry_txt[3], 
                 :pos => entry_txt[4],
                 :relation => entry_txt[5],
                 :relation_description => entry_txt[6],
                 :midashigo => entry_txt[7],
                 :relation_kind => entry_txt[8],
                 :romaji_help => entry_txt[9]
                )

  end
end
