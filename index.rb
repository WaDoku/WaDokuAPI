require 'bundler'

Bundler.require(:picky)

require_relative 'picky/misc.rb'
require_relative 'picky/indexes.rb'

Picky::Indexes.index
