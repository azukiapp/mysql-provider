require "mysql2"
require "database"


client = Mysql2::Client.new(:host => "localhost",
                            :username => "root",
                            :password => "root")
Database.inject_client(client)
