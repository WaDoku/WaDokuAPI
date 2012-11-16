require "bundler"

Bundler.require

desc "Build the index from a source file."
task :index do |t|

  require_relative "picky/misc.rb"
  require_relative "picky/indexes.rb"

  puts "Indexing source file..." 
  @romaji_index.index
end
