require 'flame_graph/color/theme/green'
require 'flame_graph/color/theme/aqua'
require 'flame_graph/color/theme/orange'
require 'flame_graph/color/theme/yellow'
require 'flame_graph/color/theme/red'

module FlameGraph
  class Color
    class Java < Theme
      def initialize config
        super

        # Memoized mono-color classes
        #
        # Handle both annotations (_[j], _[i], ...; which are accurate), as
        # well as input that lacks any annotations, as best as possible.
        # Without annotations, we get a little hacky and match on java|org|com,
        # etc.
        @java   = Color::Green.new  config
        @inline = Color::Aqua.new   config
        @kernel = Color::Orange.new config
        @cpp    = Color::Yellow.new config
        @system = Color::Red.new    config
      end

      JAVA_REGEXP = /^L?(java|javax|jdk|net|org|com|io|sun)\//

      # Override to use specific colors for specific func matches
      def rgb_for name
        case name
          when /_\[j\]$/   then @java
          when /_\[i\]$/   then @inline
          when JAVA_REGEXP then @java
          when /_\[k\]$/   then @kernel
          when /::/        then @cpp
          else @system
        end.rgb_for name
      end
    end
  end
end
