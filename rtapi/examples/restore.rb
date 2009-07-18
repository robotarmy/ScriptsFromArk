#!/usr/bin/env ruby
require 'rubygems'

require "ruby-tumblr"

Tumblr::Data.load(File.join(ENV["HOME"],"backup.xml"))
