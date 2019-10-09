module FlameGraph
  class Color
    class Aqua < Theme
      private

      def red
        50 + (60 * @v1).to_i
      end

      def green
        165 + (55 * @v1).to_i
      end
      alias blue green
    end
  end
end
