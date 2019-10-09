module FlameGraph
  class Color
    class Orange < Theme
      private

      def red
        190 + (65 * @v1).to_i
      end

      def green
        90 + (65 * @v1).to_i
      end

      def blue
        0
      end
    end
  end
end
