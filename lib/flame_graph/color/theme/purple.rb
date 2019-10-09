module FlameGraph
  class Color
    class Purple < Theme
      private

      def red
        190 + (65 * @v1).to_i
      end
      alias blue red

      def green
        80 + (60 * @v1).to_i
      end
    end
  end
end
