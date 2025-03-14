# frozen_string_literal: true

require_relative "erio/version"
require_relative "erio/short"
require'rack'
require'rack/handler/puma'

#
# An very tiny and chubby Web Framework base on Rack
# Fast and tiny Code
#
#    class Touwa < Erio
#      enter do
#        status 200
#        if header? http_accept: /image|video|audio/ and
#          not header? http_accept: /text|application/
#          header content_type: path.split('.')[-1]
#          begin
#            File.binread('public'+path)
#          rescue => err
#            puts err
#            status 404
#            'miss'
#          end
#        elsif path? '/'
#          header content_type: 'text'
#          'hi'
#        else
#          status 404
#          'miss'
#        end
#      end
#    end
class Erio
  @_enter = -> { @status=200; 'set `enter do ... end\' to set routes.'}

  def self.inherited(subclass)
    instance_variables.map { |k| subclass.instance_variable_set(k, instance_variable_get(k)) }
  end
end

class << Erio
  # App's ENTER.
  # When Request will once run
  #
  # example:
  #   class App < Erio
  #     enter do |o|
  #       o.status 200
  #       if o.path? '/'
  #         'hi'
  #       else o.status 404
  #         'miss'
  #       end
  #     end
  #   end
  #
  # @yield run for rack-triad
  # @return [String, Object] maybe response body
  def enter &blk; blk ? @_enter = blk : @_enter.arity == 1 ? @_enter.call(self) : class_exec(&@_enter) end

  def _call env
    @_env = env
    @header = {}
    @status = nil
    @body = nil
    last_res = enter
    @body ||= last_res || ''
    [@status, @header, [@body]]
  end

  # create a dup to indiv variables scope
  # and call its enter.
  # returns rack-triad for rack
  #
  # @param env
  # @return Array<Numeric, Hash, Array<String>> triad of 
  def call env
    dup._call(env)
  end

  def run!
    Rack::Handler::Puma.run(self)
  end

  def []  key; instance_variable_get :"@#{key}" end
  def []= key, value; instance_variable_set :"@#{key}", value end
end