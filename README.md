# Boppers::CoinMarketCap

A [bopper](https://github.com/fnando/boppers) to get alerts on CoinMarketCap prices.

[![Travis-CI](https://travis-ci.org/fnando/boppers-coinmarketcap.png)](https://travis-ci.org/fnando/boppers-coinmarketcap)
[![GPA](https://codeclimate.com/github/fnando/boppers-coinmarketcap/badges/gpa.svg)](https://codeclimate.com/github/fnando/boppers-coinmarketcap)
[![Test Coverage](https://codeclimate.com/github/fnando/boppers-coinmarketcap/badges/coverage.svg)](https://codeclimate.com/github/fnando/boppers-coinmarketcap)
[![Gem](https://img.shields.io/gem/v/boppers-coinmarketcap.svg)](https://rubygems.org/gems/boppers-coinmarketcap)
[![Gem](https://img.shields.io/gem/dt/boppers-coinmarketcap.svg)](https://rubygems.org/gems/boppers-coinmarketcap)

## Installation

Add this line to your application's Gemfile:

```ruby
gem "boppers-coinmarketcap"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install boppers-coinmarketcap

## Usage

Add this bopper to your configuration:

```ruby
Boppers.configure do |config|
  config.boppers << Boppers::CoinMarketCap.new(
                      ticker: "XLM",
                      operator: "less_than", # can also be "greater_than"
                      value: "0.00000405"
                    )
end
```

You can also trigger alerts based on USD; just set `unit: "USD"` like the following:

```ruby
Boppers.configure do |config|
  config.boppers << Boppers::CoinMarketCap.new(
                      ticker: "XLM",
                      operator: "less_than",
                      value: "0.05", # 5 cents
                      unit: "USD"
                    )
end
```

The default interval for this bopper is `15 seconds`, but you can set it to whatever you want by passing `interval: INTERVAL_IN_SECONDS`.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/fnando/boppers-coinmarketcap. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Boppers project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/fnando/boppers-coinmarketcap/blob/master/CODE_OF_CONDUCT.md).
