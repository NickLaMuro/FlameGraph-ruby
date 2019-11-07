rakelib = File.expand_path "..", __FILE__
$LOAD_PATH.unshift(rakelib) unless $LOAD_PATH.include?(rakelib)

require "support/changelog_helper"
require "support/github_api_helper"

namespace :github do
  desc "Create a release on github.com for NickLaMuro/FlameGraph-ruby"
  task :release => %w[git:tag git:validate] do
    GitHubAPI.create_release
  end
end
