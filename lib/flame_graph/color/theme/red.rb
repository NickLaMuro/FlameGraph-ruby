module FlameGraph
  class Color
    class Red < Theme
      private

      def red
        200 + (55 * @v1).to_i
      end

      def green
        50 + (80 * @v1).to_i
      end
      alias blue green
    end
  end
end
