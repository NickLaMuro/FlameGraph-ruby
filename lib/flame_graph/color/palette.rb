module FlameGraph
  class Color
    class Palatte
      PALETTE_FILE = "palette.map"

      attr_accessor :map
      attr_accessor :filename

      def initialize filename = PALETTE_FILE
        @filename = filename
        @map      = {}
      end

      def [] key
        @map[key]
      end

      def []= key, value
        @map[key] = value
      end

      def read?
        @read
      end

      def write
        File.open(filename, "w") do |file|
          map.keys.sort.each do |key|
            file.puts "#{key}->#{map[key]}"
          end
        end
      end

      def read
        return if defined? @read

        File.foreach(filename) do |line|
          key, value = line.chomp.split "->"
          map[key]   = value
        end if File.exist? filename

        @read = true
      end
    end
  end
end
