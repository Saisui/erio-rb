class << Erio
  def ip; @env['REMOTE_ADDR'] end
  def user_agent; @env['HTTP_USER_AGENT'] end
  def req_body; @env['rack.input'].read end
  def req_scheme; @env['rack.url_scheme'] end
  def req_host; @env['HTTP_HOST'] end
  def query; @env['QUERY_STRING'] end

  def decode_www str
    str.gsub('+','%2B').gsub(/%([\da-fA-F]{2})/) { $1.to_i(16).chr }
  end
  def encode_www str
    str.gsub(/[^ 0-9a-zA-Z\-_~]/) {|c| c.bytes.map { '%%%02X' % _1 }.join }.gsub(' ', '+')
  end

  def queries q_str=nil
    (q_str || @env['QUERY_STRING']).split('&')
    .map { k,v = [*_1.split('='),''][0,2]; [k, decode_www(v)] }.to_h
  end

  def content_type type
    type = type.to_s
    type = case type
    when *%w[html json xml yaml ruby javascript python ini toml rust go vue md markdown rdoc]
      'text/'+type
    when *%w[png jpg jpeg webp tiff gif bmp ico]
      'image/'+type
    when *%w[mp4 webm mkv mov ts]
      'video/'+type
    when *%w[mp3 ogg wav flac ape m4a midi]
      'audio/'+type
    else type
    end
    @header['content-type'] = type
  end

  def send_file filename
    ext = File.extname filename
    content_type ext
    File.binread filename
  end

  def req; Rack::Request.new(@env) end
  def header **kws; kws.empty? ? @header : @header.merge!(kws.to_a.map { [_1.to_s.tr('_','-'),_2] }.to_h) end
  def status s=nil; s ? @status=s : @status end
  def path; @env['REQUEST_PATH'] end
  def path? pattern=nil; block_given? ? (yield if pattern === path) : pattern === path end
  def verb word=nil; block_given? ? (yield if verb == word.to_s.upcase) : (word ? (@env['REQUEST_METHOD'] == word.to_s.upcase) : @env['REQUEST_METHOD']) end
  def body str=nil; str ? @body=str : @body end
  def accept; @env['HTTP_ACCEPT'] end

  def status? s=200, &block
    bool = s === @status
    return bool unless bool && block
    block.call
  end

  def ip? cond, &block
    bool = cond === @env['REMOTE_ADDR']
    return bool unless bool && block
    block.call
  end

  def header? **kws, &block
    bool = kws.keys.map { k=_1.to_s.tr('_','-'); kws[k] === @header[k] ? return false : true }.all?
    return bool unless bool && block
    block.call
  end

  def host? url, &block
    bool = url === env['HTTP_HOST']
    return bool unless bool && block
    block.call
  end

  def body?; !!@body end

  def query? **kws, &block
    bool = kws.keys.map { kws[_1] === queries[_1] ? return false : true }.all?
    return bool unless bool && block
    block.call
  end

  def accept? *types, &block
    acc = @env['HTTP_ACCEPT']
    bool = types.map do |type|
      rt = %r[\b#{type}\b]
      case type
      when nil then true
      when /\b\w+\b/i then acc =~ rt
      when Array
        type.map do |type|
          case type
          when /\b\w+\b/i then acc =~ rt
          else type === acc
          end
        end.any?
      else type === acc
      end
      # bool
    end.all?
    return bool unless bool && block
    block.call
  end

end