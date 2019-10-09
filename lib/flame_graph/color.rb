require 'flame_graph/color/palette'
require 'flame_graph/color/themes'

module FlameGraph
  class Color
    attr_accessor :bgcolor1
    attr_accessor :bgcolor2
    attr_accessor :config
    attr_accessor :negate
    attr_accessor :palette
    attr_accessor :theme

    BLACK  = "rgb(0,0,0)"
    VDGREY = "rgb(160,160,160)"
    DGREY  = "rgb(200,200,200)"

    def initialize config
      @config  = config
      @theme   = fetch_theme(config).new config
      @negate  = config[:negate]
      @palette = Palatte.new

      set_background_colors

      @palette.read if config[:cp]
    end

    def palette?
      palette.read?
    end

    def color func
      theme.rgb_for func
    end

    def color_scale value, max
      r, g, b = [255, 255, 255]
      value  *= -1 if negate

      if value > 0
        g = b = (210 * (max - value) / max).to_i
      else
        r = g = (210 * (max + value) / max).to_i
      end

      "rgb(#{r},#{g},#{b})"
    end

    def color_map func
      palette[func] ||= theme.rgb_for func
    end

    private

    def fetch_theme config
      require "flame_graph/color/theme/#{config[:colors]}"
      FlameGraph::Color::const_get config[:colors].capitalize
    rescue LoadError, NameError
      FlameGraph::Color::Theme
    end

    # background colors:
    # - yellow gradient: default (hot, java, js, perl)
    # - green gradient: mem
    # - blue gradient: io, wakeup, chain
    # - gray gradient: flat colors (red, green, blue, ...)
    #
    def set_background_colors
      bgcolors = config[:bgcolors]
      bgcolors = background_colors_from_config_colors if bgcolors.empty?

      case bgcolors
      when "yellow"
        @bgcolor1 = "#eeeeee" # background color gradient start
        @bgcolor2 = "#eeeeb0" # background color gradient stop
      when "blue"
        @bgcolor1 = "#eeeeee"
        @bgcolor2 = "#e0e0ff"
      when "green"
        @bgcolor1 = "#eef2ee"
        @bgcolor2 = "#e0ffe0"
      when "grey"
        @bgcolor1 = "#f8f8f8"
        @bgcolor2 = "#e8e8e8"
      when /^#......$/
        @bgcolor1 = @bgcolor2 = config[:bgcolors]
      else
        raise ArgumentError, "Unrecognized bgcolor option \"bgcolors\""
      end
    end

    def background_colors_from_config_colors
      case config[:colors]
      when "mem"
        "green"
      when /^(io|wakeup|chain)$/
        "blue"
      when /^(red|green|blue|aqua|yellow|purple|orange)$/
        "grey"
      else
        "yellow"
      end
    end
  end
end
