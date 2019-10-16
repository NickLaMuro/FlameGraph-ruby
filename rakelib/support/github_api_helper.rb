rakelib = File.expand_path "..", File.dirname(__FILE__)
$LOAD_PATH.unshift(rakelib) unless $LOAD_PATH.include?(rakelib)

require "support/rake_constants"

module GitHubAPI
  module_function

  def create_release
    post_data = {
      "tag_name"         => FLAMEGRAPH_VERSION_TAG,
      "name"             => FLAMEGRAPH_VERSION_TAG,
      "body"             => Changelog.release_desc,
      "draft"            => true,
      "prerelease"       => false
    }

    uri  = URI('https://api.github.com/repos/NickLaMuro/FlameGraph-ruby/releases')
    post = Net::HTTP::Post.new(uri)
    post['Authorization'] = "token #{github_auth['oauth_token']}"

    github_api.request post, post_data.to_json
  end

  def github_api
    return @github_api if defined? @github_api

    require 'net/http'

    github_ui   = URI('https://api.github.com/')
    @github_api = Net::HTTP.new(github_ui.host, github_ui.port)
  end
  private_class_method :github_api

  def github_auth
    return @github_auth if defined? @github_auth

    hub_creds_file = File.join Dir.home, ".config", "hub"
    unless File.exist? hub_creds_file
      fail "No Hub Credentials set!  Configure github auth in '#{hub_creds_file}'"
    end

    require 'yaml'

    hub_conf  = YAML.load_file hub_creds
    hub_creds = hub_conf["github.com"].detect { |auth| auth['user'] == "NickLaMuro" }

    unless hub_creds['oauth_token']
      fail "GitHub Auth token NOT FOUND!  Configure github auth in '#{hub_creds_file}'"
    end

    @github_auth = hub_creds['oauth_token']
  end
  private_class_method :github_auth
end
