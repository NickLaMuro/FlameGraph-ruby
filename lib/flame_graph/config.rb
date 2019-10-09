require 'flame_graph/color'

module FlameGraph
  module Config
    TITLE_DEFAULT  = "Flame Graph"      # (overwritten by :title)
    TITLE_CHART    = "Flame Chart"      # (overwritten by :title)
    TITLE_INVERTED = "Icicle Graph"     # (overwritten by :title)

    DEFAULTS       = {
      :fonttype      => "Verdana",
      :width         => 1200,             # max width, pixels
      :frameheight   => 16,               # height of each frame (max height is dynamic)
      :encoding      => "",
      :fontsize      => 12.0,             # base text size
      :fontwidth     => 0.59,             # avg width relative to fontsize
      :minwidth      => 0.1,              # min function width, pixels
      :title         => "",               # centered heading
      :subtitle      => "",               # second level title (optional)
      :nametype      => "Function:",      # what are the names in the data?
      :countname     => "samples",        # what are the counts in the data?
      :nameattr      => "",               # file holding function attributes
      :total         => "",               # (override the) sum of the counts
      :factor        => 1.0,              # factor to scale counts by
      :colors        => "hot",            # color theme
      :bgcolors      => "",               # background color theme
      :hash          => false,            # color by function name
      :cp            => false,            # if we use consistent palettes (default off)
      :reverse       => false,            # reverse stack order, switching merge end
      :inverted      => false,            # icicle graph
      :flamechart    => false,            # produce a flame chart (sort by time, do not merge stacks)
      :negate        => false,            # switch differential hues
      :notes         => "",               # embedded notes in SVG

      # No CLI flags
      :framepad      => 1,                # vertical padding for frames
      :titlesize     => 12.0 + 5.0,       # base text size + 5
      :fontcolor     => Color::BLACK,     # color for text in graph
      :subtitlecolor => Color::VDGREY,    # color for text in graph
      :pal_file      => "palette.map",    # palette map file name
      :palette_map   => nil,              # palette map hash
      :searchcolor   => "rgb(230,0,230)", # color for search highlighting
      :xpad          => 10
    }

    # Sets the default :title value in the options hash if it isn't already set
    #
    # If there is already a value in `:title`, then no change is done
    def self.set_default_title options
      if options[:title].empty?
        if options[:flamechart]
          options[:title] = TITLE_CHART
        elsif options[:inverted]
          options[:title] = TITLE_INVERTED
        else
          options[:title] = TITLE_DEFAULT
        end
      end
    end
  end
end
