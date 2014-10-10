module Rack
  class Parser

    POST_BODY  = 'rack.input'.freeze
    FORM_INPUT = 'rack.request.form_input'.freeze
    FORM_HASH  = 'rack.request.form_hash'.freeze

    JSON_PARSER   = proc { |data| JSON.parse data }
    ERROR_HANDLER = proc { |err, type| [400, {}, ['']] }

    attr_reader :parsers, :handlers, :logger

    def initialize(app, options = {})
      @app      = app
      @parsers  = options.delete(:parsers)  || { %r{json} => JSON_PARSER }
      @handlers = options.delete(:handlers) || {}
      @logger   = options.delete(:logger)
    end

    def call(env)
      type   = Rack::Request.new(env).media_type
      parser = parsers.detect { |content_type, _| type.match(content_type) } if type
      return @app.call(env) unless parser
      body = env[POST_BODY].read ; env[POST_BODY].rewind
      return @app.call(env) unless body && !body.empty?
      begin
        parsed = parser.last.call body
        env.update FORM_HASH => parsed, FORM_INPUT => env[POST_BODY]
      rescue StandardError => e
        warn! e, type
        handler   = handlers.detect { |content_type, _|  type.match(content_type) }
        handler ||= ['default', ERROR_HANDLER]
        return handler.last.call(e, type)
      end
      @app.call env
    end

    # Private: send a warning out to the logger
    #
    # error - Exception object
    # type  - String of the Content-Type
    #
    def warn!(error, type)
      return unless logger
      message = "[Rack::Parser] Error on %s : %s" % [type, error.to_s]
      logger.warn message
    end
  end
end
