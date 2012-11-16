require "bundler"

Bundler.require

require_relative "picky/misc.rb"
require_relative "picky/indexes.rb"
Picky::Indexes.load
require_relative "app/index.rb"
