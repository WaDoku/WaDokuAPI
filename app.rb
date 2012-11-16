require "bundler"

Bundler.require

ROOT_DIR=File.dirname(__FILE__)

require_relative "db/config.rb"

require_relative "picky/misc.rb"
require_relative "picky/indexes.rb"
Picky::Indexes.load

require_relative "app/index.rb"
