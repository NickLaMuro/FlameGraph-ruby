FLAMEGRAPH_GEMSPEC_FILE = File.expand_path File.join(*%w[.. .. flamegraph-ruby.gemspec]), __FILE__
FLAMEGRAPH_GEMSPEC      = eval File.read(FLAMEGRAPH_GEMSPEC_FILE)

def sh_opts
  [
    { [:out, :err] => File::NULL, },
    { :verbose     => false }
  ]
end

def run cmd, *args
  sh cmd, *args, *sh_opts
end
