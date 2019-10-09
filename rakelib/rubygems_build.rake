require "rubygems/package_task"
require File.expand_path "constants", File.dirname(__FILE__)

namespace :rubygems do
  Gem::PackageTask.new(FLAMEGRAPH_GEMSPEC).define

  def gem_run *args
    require "rubygems/gem_runner"
    require "rubygems/exceptions"

    Gem::GemRunner.new.run args
  end

  desc "Install the build of the gem locally"
  task :install => [:package] do
    require "rubygems"

    begin
      gem "flamegraph-ruby", FLAMEGRAPH_GEMSPEC.version
      puts "#{FLAMEGRAPH_GEMSPEC.full_name} already installed!"
    rescue LoadError
      gem_run "install", "pkg/#{FLAMEGRAPH_GEMSPEC.full_name}.gem"
    end
  end

  desc "Uninstall local package"
  task :uninstall do
    gem_run "uninstall", "-x", "flamegraph-ruby"
  end

  desc "Repackage, Uninstall and Install"
  task :reinstall => [:repackage, :uninstall, :install]
end
