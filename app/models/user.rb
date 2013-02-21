class User
  include DataMapper::Resource
  property :id, Serial
  property :client_id, Text, :unique => true
  property :client_secret, Text
end
