# AppleWarrantyCheck

[![Gem Version](https://badge.fury.io/rb/apple_warranty_check.svg)](http://badge.fury.io/rb/apple_warranty_check)
[![Build Status](https://travis-ci.org/flowerett/apple_warranty_check.svg?branch=master)](https://travis-ci.org/flowerett/apple_warranty_check)
[![Code Climate](https://codeclimate.com/github/flowerett/apple_warranty_check/badges/gpa.svg)](https://codeclimate.com/github/flowerett/apple_warranty_check)
[![Dependency Status](https://gemnasium.com/flowerett/apple_warranty_check.svg)](https://gemnasium.com/flowerett/apple_warranty_check)
[![Coverage Status](https://coveralls.io/repos/flowerett/apple_warranty_check/badge.svg)](https://coveralls.io/r/flowerett/apple_warranty_check)

Simple tool to get warranty info for Apple devices by it's IMEI from official site.

:exclamation: Apple status check page changed, gem doesn't work :exclamation:

#TODO
 - move check to https://checkcoverage.apple.com/
 - bypass captcha

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'apple_warranty_check'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install apple_warranty_check

## Usage

```ruby
require 'apple_warranty_check'
AppleWarrantyCheck::Process.new('IMEI').run
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Acknowledgments
Special thanks to [glarizza](https://github.com/glarizza/scripts/blob/master/ruby/warranty.rb) and [chorn](https://github.com/chorn/apple_warranty_check/blob/master/check) who inspired me to build this tiny lib.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/flowerett/apple_warranty_check.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

