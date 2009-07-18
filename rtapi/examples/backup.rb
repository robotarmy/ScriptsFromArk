#!/usr/bin/env ruby
require 'rubygems'
require "ruby-tumblr"

Tumblr::API.read("ruby-tumblr.dynamic-semantics.com") do |pager|
  data = Tumblr::Data.new
  0.upto(pager.last_page) do |n|
    puts "get #{n}/#{pager.last_page}"
    data << pager.page(n)
  end
  data.save(File.join(ENV["HOME"], "backup.xml"))
end
