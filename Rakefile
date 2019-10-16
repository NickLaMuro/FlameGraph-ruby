rakelib = File.expand_path "rakelib", File.dirname(__FILE__)
$LOAD_PATH.unshift(rakelib) unless $LOAD_PATH.include?(rakelib)

require "support/rake_constants"

# -----------------------------------------------
#                     Tests
# -----------------------------------------------

require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

# -----------------------------------------------
#                    Console
# -----------------------------------------------

desc "Open an irb console"
task :console do
  require 'irb'

  lib = File.expand_path("../lib", __FILE__)
  $LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

  require 'flame_graph'

  TOPLEVEL_BINDING.irb
end

# -----------------------------------------------
#                    Release
# -----------------------------------------------

desc "Release #{FLAMEGRAPH_GEM_NAME}"
task :release         => ["git:tag", "git:validate", "github:release"]

desc "Release #{FLAMEGRAPH_GEM_NAME} manually (without Github Actions)"
task "release:manual" => [:release, "rubygems:push", "github:push"]

task :default => :test
