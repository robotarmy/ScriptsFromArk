require File.dirname(__FILE__) + '/spec_helper.rb'

describe Tumblr::API::Reader do
  describe "new(:num => 5)" do
    it "should contain less than 5 posts in a page" do
      page = Tumblr::API::Reader.new($site, :num => 5)[0]
      page.posts.size.should <= 5
    end
  end

  describe "new(:type => :regular)" do
    it "should contain only regular posts in a page" do
      page = Tumblr::API::Reader.new($config["site"], :type => :regular)[0]
      page.posts.each do |post|
        post.should be_a_kind_of(Tumblr::Data::Regular)
      end
    end
  end

  describe "new(:type => :quote)" do
    it "should contain only quote posts in a page" do
      page = Tumblr::API::Reader.new($site, :type => :quote)[0]
      page.posts.each do |post|
        post.should be_a_kind_of(Tumblr::Data::Quote)
      end
    end
  end

  describe "new(:type => :photo)" do
    it "should contain only photo posts in a page" do
      page = Tumblr::API::Reader.new($site, :type => :photo)[0]
      page.posts.each do |post|
        post.should be_a_kind_of(Tumblr::Data::Photo)
      end
    end
  end

  describe "new(:type => :link)" do
    it "should contain only link posts in a page" do
      page = Tumblr::API::Reader.new($site, :type => :link)[0]
      page.posts.each do |post|
        post.should be_a_kind_of(Tumblr::Data::Link)
      end
    end
  end

  describe "new(:type => :conversation)" do
    it "should contain only conversation posts in a page" do
      page = Tumblr::API::Reader.new($site, :type => :conversation)[0]
      page.posts.each do |post|
        post.should be_a_kind_of(Tumblr::Data::Conversation)
      end
    end
  end

  describe "new(:type => :video)" do
    it "should contain only video posts in a page" do
      page = Tumblr::API::Reader.new($site, :type => :video)[0]
      page.posts.each do |post|
        post.should be_a_kind_of(Tumblr::Data::Video)
      end
    end
  end

  describe "new(:type => :audio)" do
    it "should contain only audio posts in a page" do
      page = Tumblr::API::Reader.new($site, :type => :audio)[0]
      page.posts.each do |post|
        post.should be_a_kind_of(Tumblr::Data::Audio)
      end
    end
  end

end
