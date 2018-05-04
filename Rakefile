# encoding: utf-8
require "bundler"
require 'pry'

#required for travis
if ENV['RACK_ENV'] == 'test'
  require 'rspec/core/rake_task'
end

ROOT_DIR=File.expand_path(File.dirname(__FILE__))
ENV["RACK_ENV"] ||= "staging"

task :default => "fresh_spec"

desc "Run specs"
task :spec do
  Bundler.require(:db)
  require_relative 'app/models/entry'
  require_relative 'app/models/lemma'
  require_relative 'app/models/user'
  require_relative 'db/config'

  require 'parslet'
  require_relative 'grammar/wadoku_grammar'
  require_relative 'grammar/html_transform'
  require_relative 'grammar/text_transform'
  require_relative 'grammar/tre_filter'

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

  require_relative 'app/models/entry'
  require_relative 'db/config'

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
  task(:fill_db).invoke
  task(:picky_index).invoke
  task(:spec).invoke
end

def tab_file
  case ENV['RACK_ENV']
    when 'production' then File.join(ROOT_DIR, "WaDokuJT-Data","WaDokuDa.tab")
    when 'staging' then File.join(ROOT_DIR, "WaDokuJT-Data","WaDokuDa.tab")
    when 'development' then File.join(ROOT_DIR, "WaDokuJT-Data","WaDokuDa.tab")
    when 'test' then File.join(ROOT_DIR, "WaDokuJT-Data","WaDokuTest.tab")
  end
end

desc 'Create search lemmata from database'
task :create_lemmata do
  Bundler.require(:db)
  require_relative 'app/models/entry'
  require_relative 'app/models/lemma'
  require_relative 'db/config'

  DataMapper.auto_upgrade!
  Lemma.auto_migrate!

  regex = /(LongKanji)|(?:\[.+?\])|(?:[^\p{Han}\p{Katakana}\p{Hiragana}\p{Latin}; ･ー])/

  Entry.each_slice(1000) do |slice|
    Lemma.transaction do
      slice.each do |entry|
        lemmata = entry.writing.gsub(regex ,"").split(/[; ]/).reject{|str| str == ""}
        lemmata.each do |lemma|
          Lemma.create(content:lemma, entry: entry)
        end
      end
    end
  end

end

desc "Fill DB from tab file"
task :fill_db do

  Bundler.require(:db)
  require 'parslet'
  require_relative 'app/extensions'
  SOURCE_FILE = ENV["WADOKU_SOURCE"] || tab_file

  require_relative 'app/models/entry'
  require_relative 'app/models/lemma'
  require_relative 'app/models/user'
  require_relative 'db/config'
  require_relative 'grammar/wadoku_grammar'
  require_relative 'grammar/html_transform'
  require_relative 'grammar/text_transform'
  require_relative 'grammar/tre_filter'

  grammar = WadokuGrammar.new
  plain_transformer = TextTransform.new
  html_transformer = HTMLTransform.new

  `mkdir -p db/sqlite`
  # Clear everything
  DataMapper.auto_migrate!

  source = open(SOURCE_FILE).read

  source.each_line.drop(1).each_slice(1000) do |slice|
    Entry.transaction do
      slice.each do |line|
        entry_txt = line.split("\t")

        parsed = nil
        definition_html = nil
        definition_plain = nil
        audio_url = nil
        picture_url = nil
        picture_caption = nil
        tres = nil
        begin
          parsed = grammar.parse(entry_txt[3])
          definition_html = html_transformer.apply(parsed).to_s
          definition_plain = plain_transformer.apply(parsed).to_s

          pict = parsed.subtree(:pict).first
          if pict then
            picture_caption = pict[:pict][:capt]
            picture_url = "/svg/#{pict[:pict][:filen]}.svg"
          end

          audio = parsed.subtree(:audio).first
          if audio then
            audio_url = "/audio/#{audio[:audio][:text]}.mp3"
          end
        rescue => e
        end

        entry = Entry.create(:wadoku_id => entry_txt[0],
                     :writing => entry_txt[1],
                     :kana => entry_txt[2] ,
                     :definition => entry_txt[3],
                     :definition_html => definition_html,
                     :definition_plain => definition_plain,
                     :audio_url => audio_url,
                     :picture_url => picture_url,
                     :picture_caption => picture_caption,
                     :pos => entry_txt[4],
                     :relation => entry_txt[5],
                     :relation_description => entry_txt[6],
                     :midashigo => entry_txt[7],
                     :relation_kind => entry_txt[8],
                     :romaji_help => entry_txt[9]
                    )
        entry.generate_tres! parsed

        binding.pry unless entry.saved?
      end
    end
  end

  task(:create_lemmata).invoke
end

desc "Fill Picky indexes from database"
task :picky_index do
  Bundler.require(:db, :picky)

  require_relative 'app/models/entry'
  require_relative 'app/models/lemma'
  require_relative 'picky/indexes.rb'
  require_relative 'db/config'


  puts "Indexing... This might take a while..."
  Picky::Indexes.index
end
