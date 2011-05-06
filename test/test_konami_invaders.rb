require File.expand_path('../helper', __FILE__)
require 'rack/mock'

class TestKonamiInvaders < Test::Unit::TestCase

  PAYLOAD = 'konami/invaders.js'

  context "Embedding KonamiInvaders" do
    should "place the payload at the end of the head section of an HTML request" do
      assert_match EXPECTED_CODE, request.body
    end

    should "place the payload at the end of the head section of an XHTML request" do
      response = request(:content_type => 'application/xhtml+xml')
      assert_match EXPECTED_CODE, response.body
    end

    should "not place the konami code in a non HTML request" do
      response = request(:content_type => 'application/xml', :body => [XML])
      assert_no_match EXPECTED_CODE, response.body
    end
  end

  context "Deliver payload" do
    setup do
      @expected_file = File.expand_path(File.join(%w(.. .. public) << PAYLOAD), __FILE__)
      @response = request({}, "/#{PAYLOAD}")
    end

    should "deliver #{PAYLOAD}" do
      expected = File.read(@expected_file)
      assert expected, @response.body
    end

    should "set the content-type correctly" do
      assert 'text/javascript', @response.body
    end
  end

  private

  EXPECTED_CODE = /#{PAYLOAD}/m
  
  HTML = <<-EOHTML
   <html>
     <head>
       <title>Sample Page</title>
     </head>
     <body>
       <h2>KonamiInvaders::Middleware Test</h2>
       <p>This is more test html</p>
     </body>
   </html>
  EOHTML

  XML = <<-EOXML
   <?xml version="1.0" encoding="ISO-8859-1"?>
   <user>
     <name>Some Name</name>
     <age>Some Age</age>
   </user>
  EOXML

  def request(options={}, path='/')
    @app = app(options)
    request = Rack::MockRequest.new(@app).get(path)
    yield(@app, request) if block_given?
    request
  end

  def app(options={})
    options = options.clone
    options[:content_type] ||= "text/html"
    options[:body]         ||= [HTML]
    options[:html]         || nil
    options[:delay]        || nil
    rack_app = lambda do |env|
      [ 200,
        { 'Content-Type' => options.delete(:content_type) },
        options.delete(:body) ]
    end
    KonamiInvaders::Middleware.new(rack_app, :html => options[:html], :delay => options[:delay])
  end

end
