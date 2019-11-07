rakelib = File.expand_path "..", __FILE__
$LOAD_PATH.unshift(rakelib) unless $LOAD_PATH.include?(rakelib)

require "support/rake_constants"
require 'support/rubygems_helper'

include RubygemsHelper

namespace :github do
  task :credentials do
    write_gem_credentials :github => ENV["GEM_HOST_API_KEY"] unless ENV["GEM_HOST_API_KEY"]
  end

  task :package => "rubygems:package"

  desc "Push #{FLAMEGRAPH_GEM_NAME} to rubygems.pkg.github.com"
  task :push => [:credentials, :package] do
    package = File.join "pkg", FLAMEGRAPH_GEM_NAME.full_name

    gem_run "--key",  "github",
            "--host", "https://rubygems.pkg.github.com/NickLaMuro",
            "push",   package
  end
end
