require 'flame_graph/color'

module FlameGraph
  class Color
    class Theme
      attr_accessor :hash
      attr_reader   :bgcolor1
      attr_reader   :bgcolor2

      def initialize config
        @hash = config[:hash]
      end

      def rgb_for name
        set_variance_vars name
        "rgb(#{red},#{green},#{blue})"
      end

      private

      def red
        0
      end

      def green
        0
      end

      def blue
        0
      end

      def set_variance_vars name
        if hash
          @v1 = namehash name
          @v2 = @v3 = namehash name.reverse
        else
          @v1 = rand
          @v2 = rand
          @v3 = rand
        end
      end

      # Generate a vector hash for the String (name), weighting early over
      # later characters. We want to pick the same colors for function
      # names across different flame graphs.
      def namehash name
        vector = 0
        weight = 1.0
        max    = 1.0
        mod    = 10

        # if module name present, trunc to 1st char
        chars = name.sub /.(.*?)`/, ''

        chars.each_char do |c|
          vector += ((c.ord % mod).to_f / (mod - 1)) * weight
          mod    += 1
          max    += 1 * weight;
          weight *= 0.70
          break if mod > 12
        end

        1 - (vector / max)
      end
    end
  end
end
