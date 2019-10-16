lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "flame_graph/version"

Gem::Specification.new do |spec|
  spec.name          = "flamegraph-ruby"
  spec.version       = FlameGraph::VERSION
  spec.authors       = ["Nick LaMuro"]
  spec.email         = ["nicklamuro@gmail.com"]

  spec.summary       = "Port of flamegraph.pl to Ruby"
  spec.description   = <<-DESC.gsub(/^ {4}/, '')
    Port of the FlameGraph project (https://github.com/brendangregg/FlameGraph)
    by Brendan Gregg to the Ruby programming language.  This aims completely
    mirror the output provided by that project, but be written purely in Ruby.

    If you are looking for the similarly named gem by Sam Saffron, that can be
    found at https://github.com/SamSaffron/flamegraph and on rubygems.org
    simply named "flamegraph".

    This Gem is released under the same terms as the original FlameGraph
    project using the CDDL License.
  DESC
  spec.homepage      = "https://github.com/NickLaMuro/FlameGraph-ruby"
  spec.license       = "CDDL-1.0"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = Dir["bin/*", "lib/**/*"] + %w[README.md LICENSE.txt]
  spec.bindir        = "bin"
  spec.executables   = ["flamegraph.rb"]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
