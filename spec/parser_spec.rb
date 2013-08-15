require File.expand_path('../spec_helper', __FILE__)

class FooApp
  def call(env); env; end
end

describe Rack::Parser do

  it "should have default configurations" do
    parser = Rack::Parser.new(FooApp.new).content_types

    assert_kind_of Proc, parser['application/xml']
    assert_kind_of Proc, parser['application/json']
  end

  it "should setup custom Content-Types" do
    parser = Rack::Parser.new(FooApp.new, :content_types => {
      'application/xml' => :meh,
      'application/foo' => :bar
    }).content_types

    assert_equal :meh, parser['application/xml']
    assert_equal :bar, parser['application/foo']
  end

  it "should parse JSON" do
    body = JSON.dump :test => 1, :foo => 2, :bar => 3
    post '/post', body, { 'CONTENT_TYPE' => 'application/json' }
  end

  it "should parse XML" do
    put '/post', "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<hash>\n  <a type=\"integer\">1</a>\n</hash>\n", { 'CONTENT_TYPE' => 'application/xml'}

    assert last_response.ok?
    assert_equal "{\"hash\"=>{\"a\"=>1}}", last_response.body
  end

  it "should not parse a unknown Content-Type" do
    post '/post', 'something that does not matter', { 'CONTENT_TYPE' => 'application/foo' }

    assert last_response.ok?
    assert_equal({'foo' => 'bar'}.inspect, last_response.body)
  end

  it "should return errors with a default message" do
    post '/post', "fuuuuuuuuuu", { 'CONTENT_TYPE' => 'application/json' }

    assert_equal 400, last_response.status
    assert_match %r!{"errors":"\d+: unexpected token at 'fuuuuuuuuuu'"}!, last_response.body 
  end

  it "should return a custom default error message" do
    post '/post', "fuuuuuuuuuu", { 'CONTENT_TYPE' => 'application/wahh' }

    assert_equal 500, last_response.status
    assert_equal 'wahh', last_response.body
  end

  it "should do nothing with no Content-Type" do
    get '/'

    assert last_response.ok?
    assert_match %r{Hello world}, last_response.body
  end

  it "should do nothing with unmatched Content-Type" do
    post '/post', 'foo=bar', { 'CONTENT_TYPE' => 'application/x-www-form-urlencoded' }

    assert last_response.ok?
    assert_equal({'foo' => 'bar'}.inspect, last_response.body)
  end

  it "should handle upstream errors" do
    assert_raises Exception, 'OOOPS!!' do
      post '/error', '{}', { 'CONTENT_TYPE' => 'application/json' }
    end
  end
end
