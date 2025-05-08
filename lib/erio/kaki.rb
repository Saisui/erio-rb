class << Erio
  def echo(*s)
    s.each {|s| res.write s }
  end

  def echoln(*s)
    s.each {|s| res.write s; res.write "\n"}
  end

  def slim file
    require 'slim'
    res.headers['content-type'] ||= 'text/html'
    if file in Symbol
      eval ::Slim::Template.new("views/#{file}.slim").prepare, binding
    else eval ::Slim::Template.new{file}.prepare, binding
    end
  end
end