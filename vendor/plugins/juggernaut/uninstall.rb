
require 'fileutils'

here = File.dirname(__FILE__)
there = defined?(RAILS_ROOT) ? RAILS_ROOT : "#{here}/../../.."

puts "Removing Juggernaut..."
FileUtils.rm("#{there}/public/javascripts/juggernaut.js")
FileUtils.rm("#{there}/public/juggernaut.swf")
FileUtils.rm("#{there}/script/push_server")
FileUtils.rm("#{there}/JUGGERNAUT-README")
FileUtils.rm("#{there}/config/juggernaut.yml")
FileUtils.rm("#{there}/public/crossdomain.xml")
puts "Bye..."
