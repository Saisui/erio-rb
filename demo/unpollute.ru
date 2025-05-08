require './lib/erio'
require 'securerandom'
require 'rack/session'

use Rack::Session::Cookie, secret: SecureRandom.hex(64)

class App < Erio
  enter do |o|
    o.req.session['count'] ||= 0
    o.req.session['count'] += 1
    o.echoln"session/count: #{o.req.session['count']}\n"
    o.is do
      o.echoln 'home'
    end
    o.on 'hello' do
      o.is do
        o.echoln 'hi'
      end
      o.is 'me' do
        o.echoln 'hello, self?'
      end
    end
    
    o.also
    
    o.on o.req.params.empty? do
      o.echoln "\nNo Parameters."
    end

    o.also
    
    o.on o.accept? 'text' do
      o.echoln "\nAccept: Text."
    end
  end
end

run App