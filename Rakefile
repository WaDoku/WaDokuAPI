require "bundler"
require 'rspec/core/rake_task'
require 'pry'

ROOT_DIR=File.expand_path(File.dirname(__FILE__))
ENV["RACK_ENV"] ||= "development"

task :default => "fresh_spec"

desc "Run specs"
task :spec do

  require 'parslet'
  require_relative 'grammar/wadoku_grammar'
  require_relative 'grammar/html_transform'
  require_relative 'grammar/text_transform'

  RSpec::Core::RakeTask.new(:spec) do |t|
    t.pattern = './spec/**/*_spec.rb'
  end
end

desc 'Find a non-parsing entry and build a test case'
task :find_non_parsing do
  Bundler.require(:db)
  require 'parslet'
  require_relative 'grammar/wadoku_grammar'

  SOURCE_FILE = ENV["WADOKU_SOURCE"] || tab_file

  require_relative 'db/config'
  require_relative 'app/models/entry'

  non_parsing = nil
  error = nil
  grammar = WadokuGrammar.new
  Entry.each_chunk(20) do |chunk|
    chunk.each do |entry|
      begin
        grammar.parse entry.definition
      rescue => e
        error = e
        non_parsing = entry
      end
      break if non_parsing
    end
    break if non_parsing
  end

  str = """
  # Reason:
  # #{error}
  it 'should parse this' do
    text = '#{non_parsing.definition}'
    parse = grammar.parse_with_debug(text)
    parse.should_not be_nil
  end
  """
  puts "Found, adding this to spec/grammar/parser_spec.rb:"
  puts str
  path = 'spec/grammar/parser_spec.rb'
  filetext = File.read(path)
  filetext[/end[\n]?\z/] = str + "\nend"
  File.write(path, filetext)
end

desc "Fill database, fill index, than run specs"
task :fresh_spec do
  ENV["RACK_ENV"] = "test"
  task(:fill_db).invoke
  task(:picky_index).invoke
  task(:spec).invoke
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
    source.each_line.with_index do |line, index|
      next if index == 0
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
