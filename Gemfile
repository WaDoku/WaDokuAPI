source 'https://rubygems.org/'

gem "rake"

gem "sinatra", :require => "sinatra/base"
gem "yajl-ruby", :require => 'yajl'

gem 'parslet'

group :development do
  gem "pry"
end

group :picky do
  gem "picky"
  gem 'procrastinate'
end

group :db do
  gem "romkan"
  gem "data_mapper"
  gem 'dm-chunked_query'
  gem "dm-sqlite-adapter"
  gem 'dm-is-versioned'
end

group :test do
  gem 'rspec'
  gem "rack-test", require: "rack/test"
  gem 'database_cleaner'
  gem 'dm-transactions'
end
