# Campfire adapter for Lita

## Continuous Integration

[![Build Status](https://secure.travis-ci.org/josacar/lita-campfire.png)](http://travis-ci.org/josacar/lita-campfire)
[![Coverage Status](https://coveralls.io/repos/josacar/lita-campfire/badge.png)](https://coveralls.io/r/josacar/lita-campfire)
[![Code Climate](https://codeclimate.com/github/josacar/lita-campfire.png)](https://codeclimate.com/github/josacar/lita-campfire)
[![Dependency Status](https://gemnasium.com/josacar/lita-campfire.png)](https://gemnasium.com/josacar/lita-campfire)

**lita-campfire** is an adapter for [Lita](https://github.com/jimmycuadra/lita) that allows you to use the robot with [Campfire](https://campfirenow.com).

## Installation

Add lita-campfire to your Lita instance's Gemfile:

```ruby
gem "lita-campfire"
```

or if you want to use the bleeding edge version:

```ruby
gem "lita-campfire", :git => 'https://github.com/josacar/lita-campfire.git'
```

## Configuration

Values needed to work like apikey can be found on 'My info' link when logged, subdomain and rooms, extract it from the URL to join (https://org_name_example.campfirenow.com/rooms/78744).

### Required attributes

* `apikey` (String) - The APIKEY of your robot's Campfire account. Default: `nil`.
* `rooms` (Array) - The room ids to join by your robot. Default: `nil`.
* `subdomain` (String) - The organization name to join by your robot. Default: `nil`.

### Optional attributes

* `debug` (Boolean) - If `true`, turns on the underlying Campfire library's (tinder) logger, which is fairly verbose. Default: `false`.
* `ssl_verify` (Boolean) - If `false`, turns off ssl verification in the underlying Campfire library (tinder).

**Note** You must set also `config.robot.name` and `config.robot.mention_name` to work.

### Example

This is the `lita_config.rb` file to work with campfire and be deployed on Heroku.

```ruby
Lita.configure do |config|
  # The name your robot will use.
  config.robot.name = "Campfire bot"
  config.robot.mention_name = "robot"

  # The severity of messages to log.
  config.robot.log_level = :info

  # The adapter you want to connect with.
  config.robot.adapter = :campfire

  config.adapter.subdomain = ENV["CAMPFIRE_SUBDOMAIN"]
  config.adapter.apikey = ENV["CAMPFIRE_APIKEY"]
  config.adapter.rooms = ENV["CAMPFIRE_ROOMS"].split(',')
  config.adapter.debug = false

  config.redis.url = ENV["REDISTOGO_URL"]
  config.http.port = ENV["PORT"]

  config.handlers.google_images.safe_search = :off
end
```

Then, set the variables like:

```bash
heroku config:set CAMPFIRE_APIKEY=43242c42270856780656360bfbee863892
heroku config:set CAMPFIRE_SUBDOMAIN=orgname
heroku config:set CAMPFIRE_ROOMS=5674537,324424
```

## License

[MIT](http://opensource.org/licenses/MIT)
