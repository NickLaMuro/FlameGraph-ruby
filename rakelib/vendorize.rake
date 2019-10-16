rakelib = File.expand_path "..", __FILE__
$LOAD_PATH.unshift(rakelib) unless $LOAD_PATH.include?(rakelib)

namespace :vendorize do
  desc 'Create a singlefile library for flamegraph-ruby'
  task :lib do
    require 'support/vendorize'

    Vendorize.as_lib
  end

  desc 'Create a singlefile executable for flamegraph-ruby'
  task :exe do
    require 'support/vendorize'

    Vendorize.as_exe
  end
end
