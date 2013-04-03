require "test_helper"

describe Database do

  before do
    @client_stub = stub("client", :query => true)
    Database.inject_client(@client_stub)
    @db = Database.create
  end

  it "assigns a name" do
    assert @db.name
    assert @db.name.size => 8
  end

  it "assigns a password" do
    assert @db.password
    assert @db.password.size => 8
  end

  it "has a url" do
    @db.id = 'mydb'
    @db.password = 'secret'
    assert_equal "mysql://#{Database::PREFIX}mydb:secret@localhost/#{Database::PREFIX}mydb", @db.url
  end

  #it "is included in Database.all" do
  #  assert Database.all.map(&:id).include?(@db.id)
  #end

  #it "is deleted" do
  #  @db.destroy
  #  assert !Database.all.map(&:id).include?(@db.id)
  #end

end
