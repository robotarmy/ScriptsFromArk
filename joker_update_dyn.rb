#!/usr/bin/env ruby
require 'net/http';
require 'uri';
require 'cgi';
require 'rubygems';
require 'hpricot';
#
# http://svc.joker.com/nic/update?username=username&password=password&hostname=yourhostname&myip=ipaddress&wildcard=NOCHG&mx=NOCHG&backmx=NOCHG#
#
def get_ip()
case (res = Net::HTTP.get_response(URI.parse('http://svc.joker.com/nic/checkip')))
when Net::HTTPSuccess
  return res.body.scan(/\d+\.\d+\.\d+\.\d+/)[0]
  else
   res.error!
   exit(1)
  end
end

JOKER_USER='820f27f59cfff7b0'
JOKER_PASS='db4d535f4a84257f'

def set_ip(hostname) # uses detected remote ip as myip
  require 'net/http';
  require 'uri';
  require 'cgi';
#1: Simple POST
  case (res = Net::HTTP.get_response(URI.parse('http://svc.joker.com/nic/update?'+
    {
    'username'=>JOKER_USER, 'password'=>JOKER_PASS,
    'hostname' => hostname,
    'myip' => get_ip
    }.map {|key,value|"#{key}=#{value}" }.join("&"))))
when Net::HTTPSuccess
# OK
 p res.body
exit(0)
  else
  res.error!
exit(1)
  end
end
# get_ip
 set_ip *ARGV
