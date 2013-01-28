require "bundler"
require 'rspec/core/rake_task'

ROOT_DIR=File.expand_path(File.dirname(__FILE__))

desc "Run specs"
task :spec do
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.pattern = './spec/**/*_spec.rb'
  end
end

def tab_file
  case ENV['RACK_ENV']
    when 'production' then File.join(ROOT_DIR, "WaDokuJT-Data","WaDokuDa.tab")
    when 'development' then File.join(ROOT_DIR, "WaDokuJT-Data","WaDokuDa.tab")
    when 'test' then File.join(ROOT_DIR, "WaDokuJT-Data","WaDokuTest.tab")
  end
end

desc "Fill DB from tab file"
task :fill_db do

  Bundler.require(:db)
  SOURCE_FILE = ENV["WADOKU_SOURCE"] || tab_file

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
end

desc "Fill Picky indexes from database"
task :picky_index do
  Bundler.require(:db, :picky)

  require_relative 'db/config'
  require_relative 'app/models/entry'
  require_relative 'picky/indexes.rb'

  puts "Indexing... This might take a while..."
  Picky::Indexes.index
end
