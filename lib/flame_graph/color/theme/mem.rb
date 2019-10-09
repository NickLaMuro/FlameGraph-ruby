module FlameGraph
  class Color
    class Mem < Theme
      private

      def red
        0
      end

      def green
        190 + (50 * @v2).to_i
      end

      def blue
        0 + (210 * @v1).to_i
      end
    end
  end
end
