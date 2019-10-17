module RubygemsHelper

  module_function

  # Run a `gem ...` command, but don't shell out to do it
  def gem_run *args
    require "rubygems/gem_runner"
    require "rubygems/exceptions"

    Gem::GemRunner.new.run args
  end
end
