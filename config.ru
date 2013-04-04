
# Add lib folder to LOAD_PATH
libdir = File.expand_path(File.join(File.dirname(__FILE__), "lib"))
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require "mysql_provider"

map('/heroku/resources') { run Web::Resource }
