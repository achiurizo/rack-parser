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
      post '/post', "{\"test\":1,\"foo\":2,\"bar\":\"3\"}", { 'CONTENT_TYPE' => 'application/json' }
    end

    asserts(:status).equals 200
    asserts(:body).equals "{\"test\"=>1, \"foo\"=>2, \"bar\"=>\"3\"}"
  end

  context "with xml" do
    setup do
      put '/post', "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<hash>\n  <a type=\"integer\">1</a>\n</hash>\n", { 'CONTENT_TYPE' => 'application/xml'}
    end

    asserts(:status).equals 200
    asserts(:body).equals "{\"hash\"=>{\"a\"=>1}}"
  end

  context "with custom 'foo'" do
    setup do
      post '/post', 'something that does not matter', { 'CONTENT_TYPE' => 'application/foo' }
    end

    asserts(:status).equals 200
    asserts(:body).equals({'foo' => 'bar'}.inspect)
  end

  context "for errors" do

    context "with default error message" do
      setup do
        post '/post', "fuuuuuuuuuu", { 'CONTENT_TYPE' => 'application/json' }
      end

      asserts(:status).equals 400
      asserts(:body).matches %r!{"errors":"\d+: unexpected token at 'fuuuuuuuuuu'"}!
    end

    context "with custom default error message" do
      setup do
        post '/post', "fuuuuuuuuuu", { 'CONTENT_TYPE' => 'application/wahh' }
      end

      asserts(:status).equals 500
      asserts(:body).equals "wahh"
    end
  end

  context "for get with no content_type" do
    setup { get '/' }

    asserts(:status).equals 200
    asserts(:body).matches %r{Hello world}
  end

end
