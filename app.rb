require "bundler"

Bundler.require(:default, :db, :picky, :development)
ROOT_DIR=File.expand_path(File.dirname(__FILE__))

require_relative 'grammar/wadoku_grammar'
require_relative 'grammar/text_transform'
require_relative 'grammar/html_transform'

require_relative "db/config"

require_relative 'app/models/entry'

require_relative "picky/misc"
require_relative "picky/indexes"
Picky::Indexes.load

require_relative "app/index"
