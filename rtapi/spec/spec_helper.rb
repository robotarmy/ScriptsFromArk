# load it prior to the rubygems 
# so that the local dev gets sourced first
# load the tumblr library
$KCODE = "UTF-8"
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "..", "lib")
require 'ruby-tumblr'

require 'rubygems'
# load other libraries
require 'spec'
require 'pit'

# ==========================================================
# Configuration by using Pit
# ----------------------------------------------------------
# You set $EDITOR as your favorite editor before:
# $ pit set tumblr.com
# ---
# username: your name
# site: domain name if you set a custom domain name
# password: your password
$config = Pit.get("tumblr.com")
$site = $config["site"] || $config["username"]
