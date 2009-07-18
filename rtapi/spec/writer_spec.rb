require File.dirname(__FILE__) + '/spec_helper.rb'

# Time to add your specs!
# http://rspec.rubyforge.org/
describe "ruby-tumblr write api" do
  
 it "can authenticate" do
  
    lambda { Tumblr::API.write($config["email"], $config["password"],{'group' => $config['site']}) do
     regular('hoeua')
    end }.should_not raise Tumblr::API::AuthError 
   
 end

end
