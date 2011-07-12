require 'multi_json'
require 'multi_xml'

module Rack

  # Rack::Parser allows you to set custom parsers for incoming post body data. As a default,
  # Rack::Parser uses MultiJson and MultiXml to do the decoding/parsing for you. This allows you to
  # designate any engine you wish that is compatible with the MultiJson/MultiXml libraries.
  # You can also conveniently use another library by as well by wrapping it as a Proc or add additional
  # content types which are not default in this middleware.
  #
  class Parser

    # Rack Constants
    HEADER_CONTENT_TYPE = 'Content-Type'.freeze
    POST_BODY           = 'rack.input'.freeze
    FORM_INPUT          = 'rack.request.form_input'.freeze
    FORM_HASH           = 'rack.request.form_hash'.freeze

    # Default Settings
    DEFAULT_CONTENT_TYPE = {
      'application/xml'  => Proc.new { |body| MultiXml.parse(body)   },
      'application/json' => Proc.new { |body| MultiJson.decode(body) }
    }

    attr_reader :content_types

    # Usage:
    # use Rack::Parser, :content_types = {
    #   'application/xml'  => Proc.new { |body| XmlParser.parse body   } # if you don't want the default
    #   'application/json' => Proc.new { |body| JsonParser.decode body } # if you don't want the default
    #   'application/foo'  => Proc.new { |body| FooParser.parse body   }
    # }
    def initialize(app, options = {})
      @app           = app
      @content_types = DEFAULT_CONTENT_TYPE.merge(options.delete(:content_types) || {})
    end

    def call(env)
      dup._call(env)
    end

    def _call(env)
      body = env[POST_BODY].read
      return @app.call(env) if (body.respond_to?(:empty?) ? body.empty? : !body) # Send it down the stack immediately
      content_type = env[HEADER_CONTENT_TYPE]
      format       = content_type.split('/').last
      begin
        result = @content_types[content_type].call(body)
        env.update FORM_HASH => result, FORM_INPUT => body
        @app.call env
      rescue Exception => e
        logger.warn "#{self.class} #{content_type} parsing error: #{e.to_s}" if respond_to? :logger      # Send to logger if its there.
        [400, { 'Content-Type' => content_type }, [ {'errors' => e.to_s}.method("to_#{format}").call ] ] # Finally, return an error response.
      end
    end

  end
end
