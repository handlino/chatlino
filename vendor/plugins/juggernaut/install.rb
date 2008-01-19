
require 'fileutils'

here = File.dirname(__FILE__)
there = defined?(RAILS_ROOT) ? RAILS_ROOT : "#{here}/../../.."

puts "Installing Juggernaut..."
FileUtils.cp("#{here}/media/swfobject.js", "#{there}/public/javascripts/")
FileUtils.cp("#{here}/media/juggernaut.js", "#{there}/public/javascripts/")
FileUtils.cp("#{here}/media/juggernaut.swf", "#{there}/public/")
FileUtils.cp("#{here}/media/expressinstall.swf", "#{there}/public/")
FileUtils.cp("#{here}/media/push_server", "#{there}/script/")
FileUtils.cp("#{here}/JUGGERNAUT-README", "#{there}/")
FileUtils.cp("#{here}/media/juggernaut.yml", "#{there}/config/")
puts "Congrats, Juggernaut has been installed."
puts
puts IO.read(File.join(File.dirname(__FILE__), 'JUGGERNAUT-README'))
