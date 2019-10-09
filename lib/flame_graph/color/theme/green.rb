module FlameGraph
  class Color
    class Green < Theme
      private

      def red
        50 + (60 * @v1).to_i
      end
      alias blue red

      def green
        200 + (55 * @v1).to_i
      end
    end
  end
end
