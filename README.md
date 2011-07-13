# Rack::Parser #

Rack::Parser is a Rack Middleware for parsing post body data for JSON/XML, and custom
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

use Rack::Parser, :content_types => {
  'application/json' => Proc.new { |body| MultiJson.decode body     },
  'application/xml'  => Proc.new { |body| MultiXml.decode body      },
  'application/roll' => Proc.new { |body| 'never gonna give you up' }
  }
```


By default, Rack::Parser uses MultiJson and MultiXml to decode/parse
your JSON/XML Data. these can be overwritten if you choose not to use
them. However, through using them you can just as easily leverage the
engine of your choice by setting the engine like so:


```ruby
# app.rb

MultiJson.engine = :yajl  # Yajl-ruby for json decoding
MultiXml.parser = :libxml # libxml for XML parsing

use Rack::Parser, :content_types => {
  'application/json' => Proc.new { |body| MultiJson.decode body     },
  'application/xml'  => Proc.new { |body| MultiXml.decode body      },
  'application/roll' => Proc.new { |body| 'never gonna give you up' }
  }
```

To set your own custom engine that perhaps neither MultiJson or MultiXml
support, just make it a Proc:


```ruby
use Rack::Parser, :content_types => {
  'application/json' => Proc.new { |body| MyCustomJsonEngine.do_it body }
}
```

## Inspirations ##

This project came to being because of:
* [Niko Dittmann's](https://www.github.com/niko) [rack-post-body-to-params](https://www.github.com/niko/rack-post-body-to-params) which some of its ideas are instilled in this middleware.
* Rack::PostBodyContentTypeParser from rack-contrib which proved to be an inspiration for both libraries.

## Copyright

Copyright © 2011 Arthur Chiu. See [MIT-LICENSE](https://github.com/achiu/rack-parser/blob/master/MIT-LICENSE) for details.

