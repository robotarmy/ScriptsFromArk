#!/usr/bin/env ruby -Ku

#
# Save email and password in ./test.yml before you run this.
#
require 'rubygems'
require 'pit'
require "ruby-tumblr"
require "yaml"

$conf = Pit.get 'tumblr.com' 

Tumblr::API.write($conf["email"], $conf["password"]) do
  tumblog_url = authenticate()
  regular("test body", "test title")
  regular("test body")
  regular(nil, "test title")
  quote("test quote", "test source")
  quote("test quote")
  link("http://ruby-tumblr.dynamic-semantics.com", "test link")
  link("http://ruby-tumblr.dynamic-semantics.com")
  link("http://ruby-tumblr.dynamic-semantics.com", "test link", "test description")
  photo("http://farm1.static.flickr.com/176/385411257_e7d9d37476.jpg", "test caption")
  photo("http://farm1.static.flickr.com/176/385411257_e7d9d37476.jpg")
  conversation("test1: test2", "test title")
  conversation("test1: test2")
  video("http://www.youtube.com/watch?v=QVSGRwqgvl0", "test caption")
  video("http://www.youtube.com/watch?v=QVSGRwqgvl0")
end
