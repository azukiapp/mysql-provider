require "mysql2"
require "sinatra/base"

require "database"
require "web/resource"

client = Mysql2::Client.new(:host => "localhost",
                            :username => "root",
                            :password => "root")
Database.inject_client(client)
