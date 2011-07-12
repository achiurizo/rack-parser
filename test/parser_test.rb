require File.expand_path('../teststrap', __FILE__)

class FooApp
  def call(env); env; end
end

context "Rack::Parser" do

  context "default configuration" do
    setup do
      Rack::Parser.new(FooApp.new).content_types
    end

    asserts(:[],'application/xml').kind_of Proc
    asserts(:[],'application/json').kind_of Proc
  end

  context "with custom configuration" do
    setup do
      Rack::Parser.new(FooApp.new, :content_types => {
        'application/xml' => :meh,
        'application/foo' => :bar
      }).content_types
    end

    asserts(:[], 'application/xml').equals :meh
    asserts(:[], 'application/foo').equals :bar
  end

  context "with json" do
    setup do
      post '/post', "{\"test\":1,\"foo\":2,\"bar\":\"3\"}", { 'Content-Type' => 'application/json' }
    end

    asserts(:status).equals 200
    asserts(:body).equals "{\"test\"=>1, \"foo\"=>2, \"bar\"=>\"3\"}"
  end

  context "with xml" do
    setup do
      put '/post', "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<hash>\n  <a type=\"integer\">1</a>\n</hash>\n", { 'Content-Type' => 'application/xml'}
    end

    asserts(:status).equals 200
    asserts(:body).equals "{\"hash\"=>{\"a\"=>1}}"
  end

  context "with custom 'foo'" do
    setup do
      post '/post', 'something that does not matter', { 'Content-Type' => 'application/foo' }
    end

    asserts(:status).equals 200
    asserts(:body).equals 'foo'
  end

  context "with bad data" do
    setup do
      post '/post', "fuuuuuuuuuu", { 'Content-Type' => 'application/json' }
    end

    asserts(:status).equals 400
    asserts(:body).equals "{\"errors\":\"706: unexpected token at 'fuuuuuuuuuu'\"}"
  end

end
