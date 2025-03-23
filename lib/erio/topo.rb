class << Erio
  
  # a map router for Erio.
  # nested with `on`
  # root in `is`
  # repeated slashes(/) is 1 slash:
  # `////` == `/`
  # `/hello/` == `/hello`
  #
  #   on 'hello' # match '/hello', '/hello/mine', '/hello/'
  #              # not '/helloabc'
  #   on param? :a # match '/?a'
  #   on accept? 'text' # match Header[Accept-Type] like Text.
  #
  #   class App < Erio
  #     enter do
  #       on 'hello' do
  #         res.write 'hi'
  #         on String, res.params.empty? do |name|
  #           res.write "hi, #{name}!"
  #         end
  #       end
  #     end
  #   end
  #
  # @param Bool, String, Class, Proc match path-pattern or any condition then run
  # @yield take matched args and run.
  def on(*arg)
    def path(p)
      if @_isis
        lambda {
          if env['PATH_INFO'] =~ /\A\/*(#{p}\/*)\z/
            env['SCRIPT_NAME'] += $1||''
            env['PATH_INFO'] = ''
            $1
          end
        }
      else
        lambda {
          if env['PATH_INFO'] =~ /\A\/(#{p})(\/|\z)/
            env['SCRIPT_NAME'] += "/#{$1}"
            env['PATH_INFO'] = $2 + $'
            $1
          end
        }
      end
    end

    def eq obj
      -> { _1 == obj }
    end

    def match(pat)
      case pat
      when eq(Numeric); path('\\d+(?:\\.\\d+)?').call&.yield_self {|s| s.to_f - s.to_i == 0 ? s.to_i : s.to_f }
      when eq(Integer); path('\\d+').call&.to_i
      when eq(String); path('[^\\/]+').call
      when String, Numeric; path(pat).call
      when Regexp; path(pat.source).call
      when true, false; pat
      when Proc; pat.call
      end
    end

    return if @_matched
    s, p = env['SCRIPT_NAME'], env['PATH_INFO']
    yield *arg.map { |pat| match(pat) || (@_isis=false; return) }
    env['SCRIPT_NAME'], env['PATH_INFO'] = s, p
    @_matched = true
  end

  # match path excluded rest characters
  #
  #   is 'hi' # match '/hi' not match '/hi/123'
  #   is 'hi/mine' # match '/hi/mine'
  #
  # @param String, Regexp whole match
  # @yield run if matched
  def is(*s, &block)
    s = [''] if s.empty?
    @_isis = true
    on(*s, &block)
  end

  # matched but also match another for run block
  def also; @_matched = false; end

  # alias res.finish, app needed
  def finish; res.finish; end

  def _call(env)
    @env = env
    @res = Rack::Response.new
    @req = Rack::Request.new(env)
    catch :erio_run_next_app do
      @res.status = 404 unless @_matched
      enter
      return @res.finish
    end.call(env)
  end

  attr :env, :req, :res

  def run(app)
    throw :erio_run_next_app, app
  end
end