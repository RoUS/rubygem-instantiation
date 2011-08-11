require 'rubygems'
gem 'hoe', '>= 2.1.0'
require 'hoe'
require 'fileutils'
require './lib/construction'

Hoe.plugin :newgem
Hoe.plugin :website
# Hoe.plugin :cucumberfeatures

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
$hoe = Hoe.spec 'construction' do
  self.developer('Rodent of Unusual Size',
                 'The.Rodent.of.Unusual.Size@GMail.Com')
  #
  # TODO remove if post-install message not required
  #
  self.post_install_message	= 'PostInstall.txt'
  #
  # TODO this is default value
  #
  self.rubyforge_name		= self.name
  self.version			= Construction::VERSION
  self.extra_deps		= [
                                   ['versionomy',	'>= 0.4.0'],
                                  ]

end

require 'newgem/tasks'
Dir['tasks/**/*.rake'].each { |t| load t }

# TODO - want other tests/tasks run by default? Add them to the list
# remove_task :default
# task :default => [:spec, :features]
