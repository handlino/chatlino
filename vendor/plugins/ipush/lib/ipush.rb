require "base64"
require "yaml"
require "socket"
require "json"

module Ipush
  @@config = YAML.load( File.read("#{RAILS_ROOT}/config/ipush.yml") )

  def self.config
    return @@config
  end

  def self.html_escape(s)
    s.to_s.gsub(/&/, "&amp;").gsub(/\"/, "&quot;").gsub(/>/, "&gt;").gsub(/</, "&lt;").gsub(/'/,"&#145;").gsub(/\\/, "&#92;")
  end

  def self.string_escape(s)
    # s.gsub(/[']/, '\\\\\'')
    s
  end
  
  def self.parse_string(s)
    s.gsub(/\r\n|\n|\r/, "\\n").gsub(/["']/) { |m| "\\#{m}" }
  end
  
  def self.html_and_string_escape(s)
    self.html_escape(s)
  end

end

