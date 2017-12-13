require "bundler"

Bundler.require(:default, :db, :picky, :production)
ROOT_DIR=File.expand_path(File.dirname(__FILE__))

require_relative 'app/extensions'

require_relative 'grammar/wadoku_grammar'
require_relative 'grammar/text_transform'
require_relative 'grammar/html_transform'
require_relative 'grammar/tre_filter'

# Stuff that's in the database.
require_relative 'app/models/entry'
require_relative 'app/models/lemma'
require_relative 'app/models/user'

require_relative "db/config"

# Stuff that's not.
require_relative 'app/models/json_entry'
require_relative 'app/models/results'

require_relative "picky/indexes"
Picky::Indexes.load

require_relative "app/api"
#require_relative "app/helpers/helpers"
