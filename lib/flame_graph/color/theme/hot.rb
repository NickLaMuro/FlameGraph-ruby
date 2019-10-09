module FlameGraph
  class Color
    class Hot < Theme
      private

      def red
        205 + (50 * @v3).to_i
      end

      def green
        0 + (230 * @v1).to_i
      end

      def blue
        0 + (55 * @v2).to_i
      end
    end
  end
end
