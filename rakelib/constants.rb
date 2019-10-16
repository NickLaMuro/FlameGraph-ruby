SILENT                  = true
FLAMEGRAPH_GEMSPEC_FILE = File.expand_path File.join(*%w[.. .. flamegraph-ruby.gemspec]), __FILE__
FLAMEGRAPH_GEMSPEC      = eval File.read(FLAMEGRAPH_GEMSPEC_FILE)
