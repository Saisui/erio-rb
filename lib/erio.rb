# frozen_string_literal: true

require_relative "erio/version"
require_relative "erio/short"
require'rack'
require'rack/handler/puma'

class Erio
  @_enter = -> { @status=200; 'set `enter do ... end\' to set routes.'}

  def self.inherited(subclass)
    instance_variables.map { |k| subclass.instance_variable_set(k, instance_variable_get(k)) }
  end
end

class << Erio
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

  def call env
    dup._call(env)
  end

  def run!
    Rack::Handler::Puma.run(self)
  end

  def []  key; instance_variable_get :"@#{key}" end
  def []= key, value; instance_variable_set :"@#{key}", value end

end