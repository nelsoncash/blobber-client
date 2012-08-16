require "bundler/gem_tasks"
require "bundler_geminabox"

Bundler::GemHelper.install_tasks
BundlerGeminabox::GemHelper.install

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)
task :default => :spec
