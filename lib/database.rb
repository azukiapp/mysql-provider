require 'digest/sha1'

# https://github.com/pedro/mysqlomatic/blob/master/app/models/database.rb

class Database

  PREFIX = 'dbp_'

  def self.inject_client(new_client)
    @@client = new_client
  end

  def self.client
    @@client || raise("You should set client using inject_client method")
  end

  def self.all
    databases = client.query("SHOW DATABASES", :as => :array)
    databases.inject([]) do |dbs, db_name|
      db_name = db_name.first
      if db_name =~ /^#{PREFIX}(\w+)/
        dbs << self.new($1)
      end
      dbs
    end
  end

  def self.create
    database = self.new
    database.create
    database.setup_access
    database
  end

  def self.find(id)
    id = id.gsub(PREFIX, '')
    all.detect { |db| db.id == id } || raise(RuntimeError, "Database #{id} not found")
  end

  attr_accessor :id, :password

  def initialize(id = generate_id)
    @id = id
  end

  def name
    "#{PREFIX}#{id}"
  end

  def create
    Database.client.query "CREATE DATABASE #{name}"
  end

  def setup_access
    @password = generate_id
    Database.client.query "CREATE USER '#{name}'@'%' IDENTIFIED BY '#{password}'"
    Database.client.query "CREATE USER '#{name}'@'localhost' IDENTIFIED BY '#{password}'"
    Database.client.query "GRANT ALL PRIVILEGES ON #{name}.* TO '#{name}'@'%'"
    Database.client.query "GRANT ALL PRIVILEGES ON #{name}.* TO '#{name}'@'localhost'"
    Database.client.query "FLUSH PRIVILEGES"
  end

  def destroy
    Database.client.query "DROP USER '#{name}'"
    Database.client.query "DROP DATABASE #{name}"
  end

  def url
    "mysql://#{name}:#{password}@#{ip}/#{name}"
  end

  def attributes
    { :id => id, :password => password }
  end

  protected

  def generate_id
    Digest::SHA1.hexdigest(Time.now.to_s + Time.now.usec.to_s)[8, 12]
  end

  def ip
    ENV['MYSQL_PROVIDER_IP'] || 'localhost'
  end

end
