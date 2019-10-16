rakelib = File.expand_path "..", __FILE__
$LOAD_PATH.unshift(rakelib) unless $LOAD_PATH.include?(rakelib)

namespace :vendorize do
  desc 'Create a singlefile library for flamegraph-ruby'
  task :lib => "pkg" do
    require 'support/vendorize'

    Vendorize.as_lib
  end

  desc 'Create a singlefile executable for flamegraph-ruby'
  task :exe => "pkg" do
    require 'support/vendorize'

    Vendorize.as_exe
  end

  task :all => [:lib, :exe]
end

desc 'Create all "vendorized" files'
task :vendorize => "vendorize:all"
