require 'bundler'

Bundler.require(:staging, :db)
ROOT_DIR=File.expand_path(File.dirname(__FILE__))

require_relative 'db/config'
require_relative 'app/models/entry'
require_relative 'app/models/lemma'
binding.pry
