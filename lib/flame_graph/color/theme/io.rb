module FlameGraph
  class Color
    class Io < Theme
      private

      def red
        80 + (60 * @v1).to_i
      end
      alias green red

      def blue
        190 + (55 * @v2).to_i
      end
    end
  end
end
