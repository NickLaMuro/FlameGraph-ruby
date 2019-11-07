relative_gemspec_path   = File.join *%w[.. .. .. flamegraph-ruby.gemspec]

SILENT                  = true
FLAMEGRAPH_GEMSPEC_FILE = File.expand_path relative_gemspec_path, __FILE__
FLAMEGRAPH_GEMSPEC      = eval File.read(FLAMEGRAPH_GEMSPEC_FILE)
FLAMEGRAPH_VERSION_TAG  = "v#{FLAMEGRAPH_GEMSPEC.version}"
FLAMEGRAPH_GEM_NAME     = FLAMEGRAPH_GEMSPEC.full_name
