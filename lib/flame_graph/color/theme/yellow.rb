module FlameGraph
  class Color
    class Yellow < Theme
      private

      def red
        175 + (55 * @v1).to_i
      end
      alias green red

      def blue
        50 + (20 * @v1).to_i
      end
    end
  end
end
