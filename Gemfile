source :rubygems

gem "rake"

gem "sinatra", :require => "sinatra/base"
gem "yajl-ruby", :require => 'yajl'

gem 'parslet'

group :development do
  gem "pry"
end

group :picky do
  gem "picky"
end

group :db do
  gem "romkan"
  gem "data_mapper"
  gem 'dm-chunked_query'
  gem "dm-sqlite-adapter"
end

group :test do 
  gem 'rspec'
  gem "rack-test", require: "rack/test"
end
