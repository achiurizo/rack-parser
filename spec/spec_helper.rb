gem 'minitest'
require 'minitest/autorun'
require 'rack'
require 'rack/test'
require 'rack/builder'
require 'json'

require File.expand_path('../../lib/rack/parser', __FILE__)

class Minitest::Spec
  include Rack::Test::Methods

  def app
    main_app = lambda { |env|
      request = Rack::Request.new(env)
      return_code, body_text =
      case request.path
      when '/' then [200,'Hello world']
      when '/post'
        [200,  request.params]
      when '/error'
        raise Exception, 'OOOPS!!'
      else
        [404,'Nothing here']
      end
      [return_code, {'Content-type' => 'text/plain'}, [body_text]]
    }

    builder = Rack::Builder.new
    builder.use Rack::Parser,
      :content_types => {
        'application/foo' => Proc.new { |b| {'foo' => 'bar'} } 
      },
      :error_responses => {
        'application/wahh' => Proc.new { |e, content_type| [500,{'Content-Type' => content_type},['wahh']]}
      }
    builder.run main_app
    builder.to_app
  end
end
