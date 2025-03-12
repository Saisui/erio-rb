# frozen_string_literal: true

require_relative "erio/version"

class Erio
  @_before = -> {}
  @_after  = -> {}
  @_middle = -> { @status=200; 'set `middle do ... end\' to set routes.'}
  def self.inherited(subclass)
    instance_variables.map { |k| subclass.instance_variable_set(k, instance_variable_get(k)) }
  end
end

class << Erio
  def middle &blk; blk ? @_middle = blk : @_middle.call(*[self][0,@_middle.arity]) end
  def before &blk; blk ? @_before = blk : @_before.arity == 1 ? @_before.call(self)  : @_before.call end
  def after  &blk; blk ? @_after  = blk : @_after.arity  == 1 ? @_after.call(self)   : @_after.call  end
  def logger
    puts "#{@_env['REMOTE_ADDR']} - [#{Time.now}] \"#{@_env['REQUEST_METHOD']} #{@_env['PATH_INFO']}?#{@_env['QUERY_STRING']} #{@_env['rack.url_scheme']}\" [#{@_env['HTTP_ACCEPT']}] #{"%.4fs" % @_spent.to_f}"
  end

  def main env
    @_env = env
    @header = {}
    @status = nil
    @body = nil
    @_t0 = Time.now
    before
    @body ||= middle || ''
    @_spent = Time.now - @_t0
    logger
    after
    [@status,@header,[@body]]
  end

  def call env
    self.dup.main(env)
  end

  def []  key; instance_variable_get :"@#{key}" end
  def []= key, value; instance_variable_set :"@#{key}", value end

end