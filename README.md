# Erio

A very chubby, tiny and lightweight Web Framework(base on Rack)

## Installation

```bash
gem install erio
```

## Usage

```ruby
require 'erio'

class App < Erio
  middle do
    if path? '/'
      status 200
      header content_type: 'html'
      body '<h1>Hello, Erio!</h1>'
    else
  end
end

```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/erio. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/erio/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
