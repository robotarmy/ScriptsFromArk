#!/usr/bin/ruby

require "net/http"
require "uri"
require "rexml/document"
require "tzinfo"
require "time"
require "ruby-tumblr/version"
require "mechanize"

module Tumblr
  class Data
    attr_accessor :tumblelog, :posts

    def initialize(doc = nil)
      if doc
        @tumblelog = Tumblelog.new(REXML::XPath.first(doc, "//tumblelog"))
        @posts = Posts.new(REXML::XPath.first(doc, "//posts"), @tumblelog.timezone)
      end
    end

    def self.load(path)
      new(REXML::Document.new(File.read(path)))
    end

    def save(path)
      File.open(path, "w") do |file|
        doc = REXML::Document.new
        root = doc.add_element "ruby-tumblr", {"version" => "0.1"}
        root.elements << @tumblelog.to_xml if @tumblelog
        root.elements << @posts.to_xml if @posts
        doc.write(file)
      end
    end

    def <<(other)
      @tumblelog = other.tumblelog unless @tumblelog
      @posts ? @posts.push(*other.posts) : @posts = other.posts
    end

    # Tumblelog represents tumblog informations.
    class Tumblelog
      # user name
      attr_accessor :name
      # timezone is a TZInfo::Timezone object
      attr_accessor :timezone
      # cname if the tumblelog sets
      attr_accessor :cname
      # tumblog title
      attr_accessor :title
      # description
      attr_accessor :description

      def initialize(elt)
        elt.attributes.each do |key, val|
          case key
          when "name"    ; @name     = val
          when "timezone"; @timezone = TZInfo::Timezone.get(val)
          when "cname"   ; @cname    = val
          when "title"   ; @title    = val
          end
        end
        @description = elt.text
      end

      def to_xml
        elt = REXML::Element.new("tumblelog")
        elt.attributes["name"] = @name
        elt.attributes["timezone"] = @timezone.name
        elt.attributes["cname"] = @cname
        elt.attributes["title"] = @title
        elt.text = @description
        return elt
      end
    end

    class Posts < Array
      attr_accessor :total, :start, :type

      def initialize(elt, tz)
        elt.attributes.each do |key, val|
          case key
          when "total"; @total = val.to_i
          when "start"; @start = val.to_i
          when "type" ; @type  = val
          end
        end

        elt.each_element("post") do |e|
          push((case e.attributes["type"]
                when "regular"     ; Regular
                when "quote"       ; Quote
                when "photo"       ; Photo
                when "link"        ; Link
                when "video"       ; Video
                when "conversation"; Conversation
                when "audio"       ; Audio
          end).new(e, tz))
        end
      end

      def to_xml
        elt = REXML::Element.new("posts")
        elt.attributes["total"] = @total
        elt.attributes["type"] = @type
        each do |post|
          elt.elements << post.to_xml
        end
        return elt
      end
    end

    class Post
      attr_reader :id, :url, :date, :bookmarklet

      # Setter/Reader of the post type name.
      def self.post_type(sym = nil)
        sym ? @post_type = sym : @post_type
      end

      def initialize(elt, tz)
        elt.attributes.each do |key, val|
          case key
          when "id"      ; @id          = val
          when "url"     ; @url         = val
          when "date"    ; @date        = Time.parse(val + tz.strftime("%Z"))
          when "bookmark"; @bookmarklet = (val == "true")
          end
        end
        @timezone = tz
      end

      def to_xml
        elt = REXML::Element.new("post")
        elt.attributes["id"] = @id
        elt.attributes["date"] = @date.strftime("%a, %d %b %Y %X")
        elt.attributes["bookmarklet"] = "true" if @bookmarklet
        elt.attributes["url"] = @url.to_s
        elt.attributes["type"] = self.class.post_type.to_s
        return elt
      end

      def bookmarklet?
        @bookmarklet
      end

      # Backword compatibility for 0.0.x.
      def postid
        warn "Post#postid is deprecated, use #id."
        @id
      end
    end

    class Regular < Post
      post_type :regular

      attr_accessor :title, :body

      def initialize(elt, tz)
        super
        elt.elements.each do |e|
          case e.name
          when "regular-title"; @title = e.text
          when "regular-body" ; @body  = e.text
          end
        end
      end

      def to_xml
        elt = super
        elt.add_element("regular-title").add_text(@title) if @title
        elt.add_element("regular-body").add_text(@body) if @body
        return elt
      end
    end

    class Quote < Post
      post_type :quote

      attr_accessor :text, :source

      def initialize(elt, tz)
        super
        elt.elements.each do |e|
          case e.name
          when "quote-text"  ; @text   = e.text
          when "quote-source"; @source = e.text
          end
        end
      end

      def to_xml
        elt = super
        elt.add_element("quote-text").add_text(@text)
        elt.add_element("quote-source").add_text(@source) if @source
        return elt
      end
    end

    class Photo < Post
      post_type :photo

      attr_accessor :caption, :urls

      def initialize(elt, tz)
        super
        @urls = Hash.new
        elt.elements.each do |e|
          case e.name
          when "photo-caption"; @caption = e.text
          when "photo-url"
            @urls[e.attributes["max-width"].to_i] = e.text
          end
        end
      end

      def to_xml
        elt = super
        elt.add_element("photo-caption").add_text(@caption) if @caption
        @urls.each do |width, url|
          elt.add_element("photo-url",
                          "max-width" => width.to_s).add_text(url.to_s)
        end
        return elt
      end
    end

    class Link < Post
      post_type :link

      attr_accessor :text, :url, :description

      def initialize(elt, tz)
        super
        elt.elements.each do |e|
          case e.name
          when "link-text"       ; @text        = e.text
          when "link-url"        ; @url         = e.text
          when "link-description"; @description = e.text
          end
        end
      end

      def to_xml
        elt = super
        elt.add_element("link-text").add_text(@text)
        elt.add_element("link-url").add_text(@url.to_s)
        elt.add_element("link-description").add_text(@description)
        return elt
      end

      # Backward compatibility for 0.0.x
      def name
        warn "Link#name is deprecated, use Link#text."
        @text
      end
    end

    class Conversation < Post
      post_type :conversation

      class Line
        attr_reader :name, :label, :text
        def initialize(elt)
          @name  = elt.attributes["name"]
          @label = elt.attributes["label"]
          @text  = elt.text
        end
      end

      attr_accessor :title, :lines

      def initialize(elt, tz)
        super
        @lines = []
        elt.elements.each do |e|
          case e.name
          when "conversation-title"; @title = e.text
          when "conversation-text" ; @text  = e.text
          when "conversation-line" ; @lines << Line.new(e)
          end
        end
      end

      def to_xml
        elt = super
        elt.add_element("conversation-title").add_text(@title) if @title
        elt.add_element("conversation-text").add_text(@text)
        @lines.each do |line|
          elt.add_element("conversation-line",
                          { "name"  => line.name,
                            "label" => line.label }).add_text(line.text)
        end
        return elt
      end
    end

    class Video < Post
      post_type :video

      attr_reader :caption, :source, :player

      def initialize(elt, tz)
        super
        elt.elements.each do |e|
          case e.name
          when "video-caption"; @caption = e.text
          when "video-source" ; @source  = e.text
          when "video-player" ; @player  = e.text
          end
        end
      end

      def to_xml
        elt = super
        elt.add_element("video-caption").add_text(@caption)
        elt.add_element("video-player").add_text(@player)
        elt.add_element("video-source").add_text(@source)
        return elt
      end
    end

    class Audio < Post
      post_type :audio

      attr_reader :caption, :player

      def initialize(elt, tz)
        super
        elt.elements.each do |e|
          case e.name
          when "audio-caption"; @caption = e.text
          when "audio-player" ; @player  = e.text
          end
        end
      end

      def to_xml
        elt = super
        elt.add_element("audio-caption").add_text(@caption)
        elt.add_element("audio-player").add_text(@player)
        return elt
      end
    end
  end

  module API
    class ResponseError < StandardError
      attr_reader :response
      def initialize(response)
        @response = response
      end
    end

    class AuthError < StandardError; end

    class BadRequestError < StandardError
      attr_reader :message
      def initialize(message)
        @message = message
      end
    end

    class Reader
      attr_accessor :http, :start, :num, :type, :total

      # params:
      # - :num is the number of data including a page
      # - :type is post type limitation
      def initialize(hostname, params={})
        if hostname.include?(".")
          @hostname = hostname
        else
          @hostname = hostname + ".tumblr.com"
        end
        @num = params[:num] || 20
        @num = 50 if @num > 50
        @type = params[:type]
        @total = request(:start => 0, :num => 0).posts.total
      end

      def last_page
        ((@total - 1) / @num) + 1
      end

      # Get a page.
      def page(pos)
        request(:start => pos*@num, :num => @num)
      end

      alias [] page

      # Find a post by id.
      def post(postid)
        request(:id => postid).posts.first
      end

      def start(&block)
        Net::HTTP.start(@hostname) do |http|
          @http = http
          eval &block if block_given?
        end
        @http = nil
      end

      private

      def connect
        @http.finish if @http
        @http = Net::HTTP.new(@hostname)
        @http.start
      end

      def disconnect
        @http = nil
      end

      def request(params)
        connect
        req = Net::HTTP::Post.new "/api/read"

        # setup parameters
        data = Hash.new
        if params.has_key?(:start)
          data = {"start" => params[:start], "num" => params[:num]}
          data["type"] = @type if @type
        elsif params.has_key?(:id)
          data["id"] = params[:id]
        else
          raise BadRequestError
        end

        req.set_form_data data
        res = @http.request(req)
        if res.kind_of?(Net::HTTPSuccess)
          return Tumblr::Data.new(REXML::Document.new(res.body))
        else
          raise ResponseError.new(res)
        end
      end
    end

    def self.read(hostname, *args, &b)
      # backward compatibility for 0.0.x.
      params = Hash.new
      if args[0].kind_of?(Hash)
        params.update(args[0])
      else
        params[:num]  = args[0] || 20
        params[:type] = args[1] || nil
      end

      reader = Reader.new(hostname, params)
      reader.start(&b)
      reader
    end

    class Writer
      attr_accessor :email, :password, :params

      def initialize(email, password,params={})
        @email = email
        @password = password
        @params = params
      end

      def authenticate
        post("action" => "authenticate")
      end

      def authenticated?
        begin
          authenticate
          true
        rescue AuthError
          return false
        end
      end

      # Regualar Post.
      # - title
      # - body (HTML is allowed)
      #
      # ex.
      # - writer.regular(:body => "test body", :title => "test title")
      # - writer.regular(body)
      # - writer.regular(body, title)
      def regular(*args)
        if args[0].kind_of?(Hash)
          post({:type => "regular"}.update(args[0]))
        else
          body, title, dummy = args
          post(:type => "regular", :title => title, :body => body)
        end
      end

      # Quote Post.
      # - text
      # - source (optional, HTML allowed)
      #
      # ex.
      # - writer.quote(:quote => "test text", :source => "source")
      # - writer.quote(text)
      # - writer.quote(text, source)
      def quote(*args)
        if args[0].kind_of?(Hash)
          post({:type => "quote"}.update(args[0]))
        else
          text, source, dummy = args
          post(:type => "quote", :quote => text, :source => source)
        end
      end

      def photo(source, caption=nil)
        post(:type => "photo", :caption => caption, :source => source)
      end

      def link(url, name=nil, description=nil)
        post(:type => "link", :name => name, :url => url,
             :description => description)
      end

      def conversation(conversation, title=nil)
        post(:type => "conversation", :title => title,
             :conversation => conversation)
      end

      def video(embed, caption=nil)
        post(:type => "video", :embed => embed, :caption => caption)
      end

      # Check you can post more video files today or not.
      def check_vimeo
        post(:action => "check-vimeo")
      end

      # Check you can post more audio files today or not.
      def check_audio
        post(:action => "check-audio")
      end

      # Delete the post. This is not Tumblr API, but is very helpful.
      def delete(postid)
        prepare_agent unless @agent
        if postid.kind_of?(Tumblr::Data::Post)
          postid = postid.id
        end
        @agent.post('http://www.tumblr.com/delete', "id" => postid)
      end

      private

      def connect
        @http.finish if @http
        @http = Net::HTTP.new("www.tumblr.com")
        @http.start
      end

      def prepare_agent
        @agent = WWW::Mechanize.new
        @agent.post('http://www.tumblr.com/login',
                   "email" => @email,
                   "password" => @password)
      end

      def post(data)
       p 11
        connect
        req = Net::HTTP::Post.new "/api/write"       
        req.set_form_data(params.merge({
          "email" => @email,
          "password" => @password,
        }).merge(data))
        res = @http.request req
        case res.code
        when '200', '201'
          return res.body.chomp
        when '403'
          raise AuthError.new
        when '400'
          raise BadRequestError.new(res.body)
        else
          raise ResponseError.new(res)
        end
      end
    end

    def self.write(email, password, params = {:generator => "ruby-tumblr"}, &b)
      # backward compatibility for 0.0.x.
      unless params.kind_of?(Hash)
        params = {:generator => params}
      end

      writer = Writer.new(email, password, params)
      writer.instance_eval &b if block_given?
      return writer
    end

  end
end
