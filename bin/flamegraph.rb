#!/usr/bin/env ruby

lib = File.expand_path(File.join(*%w[.. .. lib]), __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "flame_graph/cli"

FlameGraph::CLI.run
