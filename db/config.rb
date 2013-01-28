def database_file
  case ENV['RACK_ENV']
    when 'production' then 'wdk_db'
    when 'development' then 'wdk_db'
    when 'test' then 'wdk_db_test'
  end
end
DataMapper.setup(:default, "sqlite://#{ROOT_DIR}/db/sqlite/#{database_file}.sqlite3")
