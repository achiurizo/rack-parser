# Rack::Parser #

Rack::Parser is a Rack Middleware for parsing post body data for JSON, XML, and custom
content types using MultiJson, MultiXML, or any thing that you want to
use.

What this allows your rack application to do is decode/parse incoming post data
into param hashes for your applications to use.

## Installation ##

install it via rubygems:

```
gem install rack-parser
```

or put it in your Gemfile:

```ruby
# Gemfile

gem 'rack-parser', :require => 'rack/parser'
```


## Usage ##


In a Sinatra or [Padrino](http://padrinorb.com) application, it would probably be something like:

```ruby
# app.rb

use Rack::Parser
```


### Content Type Parsing ###

By default, Rack::Parser uses MultiJson and MultiXml to decode/parse
your JSON/XML Data. these can be overwritten if you choose not to use
them. However, through using them you can just as easily leverage the
engine of your choice by setting the engine like so:


```ruby
# app.rb

MultiJson.engine = :yajl  # Yajl-ruby for json decoding
MultiXml.parser  = :libxml # libxml for XML parsing

use Rack::Parser
```

To set your own custom engine that perhaps neither MultiJson or MultiXml
support, just make it a Proc:


```ruby
use Rack::Parser, :content_types => {
  'application/json' => Proc.new { |body| MyCustomJsonEngine.do_it body },
  'application/xml'  => Proc.new { |body| MyCustomXmlEngine.decode body },
  'application/roll' => Proc.new { |body| 'never gonna give you up'     }
}
```

### Error Handling ###

Rack::Parser comes with a default error handling response that is sent
if an error is to occur. If a `logger` is present, it will try to `warn`
with the content type and error message.

You can additionally customize the error handling response as well to
whatever it is you like:

```ruby
use Rack::Parser, :error_responses => {
  'default'          => Proc.new { |e, content_type| [500, {}, ["boo hoo"] ] },
  'application/json' => Proc.new { |e, content_type| [400, {'Content-Type'=>content_type}, ["broke"]] }
  }
```

The error handler expects to pass both the `error` and `content_type` so
that you can use them within your responses. In addition, you can
override the default response as well.

If no content_type error handling response is present, it will use the
`default`.

## Inspirations ##

This project came to being because of:

* [Niko Dittmann's](https://www.github.com/niko) [rack-post-body-to-params](https://www.github.com/niko/rack-post-body-to-params) which some of its ideas are instilled in this middleware.
* Rack::PostBodyContentTypeParser from rack-contrib which proved to be an inspiration for both libraries.


## External Sources/Documentations

* [Sinatra recipes](https://github.com/sinatra/sinatra-recipes/blob/master/middleware/rack_parser.md) - mini tutorial on using rack-parser (thanks to [Eric Gjertsen](https://github.com/ericgj))


## Contributors ##

* [Stephen Becker IV](https://github.com/sbeckeriv) - For initial custom error response handling work.
* [Tom May](https://github.com/tommay) - skip loading post body unless content type is set.
* [Moonsik Kang](https://github.com/deepblue) - skip rack parser for content types that are not explicitly set.

## Copyright

Copyright © 2011 Arthur Chiu. See [MIT-LICENSE](https://github.com/achiu/rack-parser/blob/master/MIT-LICENSE) for details.

