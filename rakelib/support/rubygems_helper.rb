module RubygemsHelper

  module_function

  # Run a `gem ...` command, but don't shell out to do it
  def gem_run *args
    require "rubygems/gem_runner"
    require "rubygems/exceptions"

    Gem::GemRunner.new.run args
  end

  # Create a gem_credentials file if the GEM_HOST_API_KEY ENV var is set
  def gem_credentials creds = nil
    if ENV["GEM_HOST_API_KEY"]
      require 'yaml'

      creds ||= { :rubygems_api_key => ENV["GEM_HOST_API_KEY"] }

      mkdir_p File.dirname(Gem.configurations.credentials_path)
      touch   Gem.configurations.credentials_path
      chmod   0600, Gem.configurations.credentials_path

      File.write Gem.configurations.credentials_path, creds.to_yaml
    end
  end
end
