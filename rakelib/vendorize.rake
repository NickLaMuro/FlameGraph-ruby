namespace :vendorize do
  desc 'Create a singlefile library for flamegraph-ruby'
  task :lib do
    require File.expand_path File.join('..', 'support', 'vendorize'), __FILE__

    Vendorize.as_lib
  end

  desc 'Create a singlefile executable for flamegraph-ruby'
  task :exe do
    require File.expand_path File.join('..', 'support', 'vendorize'), __FILE__

    Vendorize.as_exe
  end
end
