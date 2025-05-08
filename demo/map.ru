require './lib/erio'
require 'securerandom'
require 'rack/session'
use Rack::Session::Cookie, secret: SecureRandom.hex(64)
class App < Erio
  enter do
    req.session['count'] ||= 0
    req.session['count'] += 1
    res.write "session/count: #{req.session['count']}\n"
    is do
      res.write 'home'
    end
    on 'hello' do
      is do
        res.write 'hi'
      end
      is 'me' do
        res.write 'hello, self?'
      end
    end
    
    also
    
    on req.params.empty? do
      res.write "\nNo Parameters."
    end

    also
    
    on accept? 'text' do
      res.write "\nAccept: Text."
    end
  end
end

run App