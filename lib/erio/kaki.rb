class << Erio
  def echo(*s)
    s.each {|s| res.write s }
  end
  def echoln(*s)
    s.each {|s| res.write s; res.write "\n"}
  end
end