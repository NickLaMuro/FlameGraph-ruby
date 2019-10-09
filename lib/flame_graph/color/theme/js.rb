require 'flame_graph/color/theme/green'
require 'flame_graph/color/theme/aqua'
require 'flame_graph/color/theme/orange'
require 'flame_graph/color/theme/yellow'
require 'flame_graph/color/theme/red'

module FlameGraph
  class Color
    class Js < Theme
      def initialize config
        super

        # Memoized mono-color classes
        #
        # Handle both annotations (_[j], _[i], ...; which are accurate), as
        # well as input that lacks any annotations, as best as possible.
        # Without annotations, we get a little hacky and match on a "/" with a
        # ".js", etc.
        @source  = Color::Green.new  config
        @builtin = Color::Aqua.new   config
        @cpp     = Color::Yellow.new config
        @kernel  = Color::Orange.new config
        @system  = Color::Red.new    config
      end

      JAVA_REGEXP = /^L?(java|javax|jdk|net|org|com|io|sun)\//

      # Override to use specific colors for specific func matches
      def rgb_for name
        case name
          when /_\[j\]$/                        # jit annotation
            name =~ /\// ? @source : @builtin
          when /::/        then @cpp            # C++
          when /\/.*\.js/  then @source         # JavaScript (match "/" in path)
          when /:/         then @builtin        # JavaScript (match ":" in builtin)
          when /^ $/       then @source         # Missing symbol
          when /_\[k\]$/   then @kernel         # kernel
          else @system                          # system
        end.rgb_for name
      end
    end
  end
end
