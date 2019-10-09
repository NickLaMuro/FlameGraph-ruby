require 'flame_graph/color/theme/aqua'
require 'flame_graph/color/theme/blue'

module FlameGraph
  class Color
    class Chain < Theme
      def initialize config
        super

        # Memoized mono-color classes
        @waker   = Color::Aqua.new config
        @off_cpu = Color::Blue.new config
      end

      # Override to use specific colors for specific func matches
      def rgb_for name
        case name
          when /_\[w\]$/     then @waker
          else @off_cpu
        end.rgb_for name
      end
    end
  end
end
