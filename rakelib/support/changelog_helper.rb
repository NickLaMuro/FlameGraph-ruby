rakelib = File.expand_path "..", File.dirname(__FILE__)
$LOAD_PATH.unshift(rakelib) unless $LOAD_PATH.include?(rakelib)

require "support/rake_constants"

module Changelog
  VERSION_HEADER_MATCH = /^(v(?:\d+\.){2}\d+[\-0-9a-zA-Z]*)$/

  module_function

  # Capture the CHANGELOG.md for this version only
  def release_desc
    return @release_desc if defined? @release_desc

    release_info = []

    File.foreach "CHANGELOG.md" do |line|
      version_header = line.match ::Changelog::VERSION_HEADER_MATCH
      break if version_header && version_header[1] != FLAMEGRAPH_VERSION_TAG

      release_info << line
    end

    @release_desc = release_info.join
  end
end
