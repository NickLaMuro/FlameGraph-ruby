# == FlameGraph::Config::Options
#
# An option parser for the FlameGraph::Config
#
# Takes commandline flags similar to the original flamegraph.pl
#

require 'optparse'

module FlameGraph
  module Config
    class Options < OptionParser
      attr_accessor :options

      def initialize *args
        super

        @options = DEFAULTS.dup

        usage "USAGE: #{program_name} [options] infile > outfile.svg"

        info  'Color Options:'
        info  ''
        info  '  PALETTE:  hot, mem, io, wakeup, chain, java, js, perl,'
        info  '            red, green, blue, aqua, yellow, purple, orange'
        info  ''
        info  '  COLOR:    yellow, blue, green, grey (gradients)'
        info  '            flat colors use "#rrggbb"'
        info  ''
        info  'Options:'
        info  ''

        opt :title,       'change title text'
        opt :subtitle,    'second level title (optional)'
        opt :width,       'width of image (default 1200)'
        opt :frameheight, 'height of each frame (default 16)'
        opt :minwidth,    'omit smaller functions (default 0.1 pixels)'
        opt :encoding
        opt :fonttype,    'font type  (default "Verdana")'
        opt :fontsize,    'font width (default 0.59)'
        opt :fontsize,    'font size  (default 12)'
        opt :countname,   'count type label (default "samples")'
        opt :nameattr,    'file holding function attributes'
        opt :nametype,    'name type label (default "Function:")'
        opt :total,       '(override the) sum of the counts'
        opt :factor,      'factor to scale counts by'
        opt :colors,      'set color palette (default "hot")'
        opt :bgcolors,    'set background colors (default "yellow")'
        opt :hash,        'colors are keyed by function name hash'
        opt :cp,          'use consistent palette (palette.map)'
        opt :reverse,     'generate stack-reversed flame graph'
        opt :inverted,    'icicle graph'
        opt :flamechart,  'produce a flame chart (sort by time, do not merge stacks)'
        opt :negate,      'switch differential hues (blue<->red)'
        opt :notes,       'add notes comment in SVG (for debugging)'

        on  '--help',     'this message', display_help
      end

      alias info separator

      # Override `OptionParser#parse!` to return `@options` instead, and set a
      # few defaults after parsing.
      def parse! *args
        super

        Config.set_default_title @options
        @options
      end

      private

      TYPE_TO_S = {
        Integer => "NUM",
        Float   => "NUM",
        String  => "TEXT"
      }

      # Generic option definition setter.
      #
      # Allows for a shorthand above and does a few extra bits of logic to
      # somewhat match the "--help" output from the original.
      #
      def opt arg, description = ""
        type  = DEFAULTS[arg]
        type  = type ? type.class : nil # no 'type' for `false` (is a switch)

        # A few custom "VALUE" types (still just strings)
        val   = "PALETTE"         if arg == :colors
        val   = "COLOR"           if arg == :bgcolors
        val   = "FONT"            if arg == :fonttype

        val   = TYPE_TO_S[type]   if val.nil? && type

        flag  = "--#{arg}"
        flag += " #{val}"         if val

        block = lambda { |val| @options[arg] = val }

        on *[flag, type, description].compact, &block
      end

      # Usage text shorthand
      def usage text
        set_banner text
        separator  ''
      end

      def display_help
        lambda { |_| puts help; exit }
      end
    end
  end
end
