module FlameGraph
  class Color
    class Blue < Theme
      private

      def red
        80 + (60 * @v1).to_i
      end
      alias green red

      def blue
        205 + (50 * @v1).to_i
      end
    end
  end
end
