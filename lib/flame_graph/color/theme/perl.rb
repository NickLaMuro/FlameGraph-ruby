require 'flame_graph/color/theme/yellow'
require 'flame_graph/color/theme/green'
require 'flame_graph/color/theme/orange'
require 'flame_graph/color/theme/red'

module FlameGraph
  class Color
    class Perl < Theme
      def initialize config
        super

        # Memoized mono-color classes
        @cpp    = Color::Yellow.new config
        @perl   = Color::Green.new  config
        @kernel = Color::Orange.new config
        @system = Color::Red.new    config
      end

      # Override to use specific colors for specific func matches
      def rgb_for name
        case name
          when /::/          then @cpp
          when /(Perl|\.pl)/ then @perl
          when /_\[k\]$/     then @kernel
          else @system
        end.rgb_for name
      end
    end
  end
end
