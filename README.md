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
    status 200
    header content_type: 'html'
    if path? '/'
      '<h1>Hello, Erio!</h1>'
    elsif query? id: 1
      header content_type: 'json'
      { id: 1, name: 'Touwa Erio', country: 'Japan' }.to_json
    else
      status 404
      "<h1><b>404</b> - not found page</h1><hr><h2>\"#{path}\"</h2>"
    end
  end
end

App.run!

```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/saisui/erio-rb. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/saisui/erio-rb/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
