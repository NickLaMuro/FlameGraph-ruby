require 'flame_graph'
require 'flame_graph/config/options'

module FlameGraph
  class CLI

    attr_reader :config
    attr_reader :data

    def self.run
      new.run
    end

    def initialize cli_args = ARGV
      @config = Config::Options.new.parse! cli_args
      @data   = Data.digest ARGF, @config
    end

    def run
      svg = SVG.new @config.merge(:data => @data)
      puts svg.draw!
      svg.color.palette.write if config[:cp]
    rescue SVG::NoStacksProvided => e
      warn e.message
      puts svg.error_svg!
      exit 2
    end
  end
end
