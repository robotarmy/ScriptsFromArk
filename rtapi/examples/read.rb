#!/usr/bin/env ruby -Ku
require 'rubygems'

require "ruby-tumblr"

Tumblr::API.read("ruby-tumblr.dynamic-semantics.com") do |pager|
  data = pager.page(0)
  p data.tumblelog
  data.posts.each do |post|
    p post
  end
end
