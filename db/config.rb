puts ROOT_DIR
DataMapper.setup(:default, "sqlite://#{ROOT_DIR}/db/wdk_db.sqlite3")
