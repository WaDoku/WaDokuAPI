puts ROOT_DIR
DataMapper.setup(:default, "sqlite://#{ROOT_DIR}/db/sqlite/wdk_db.sqlite3")
