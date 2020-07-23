require "erb"
require "flame_graph/color"

module FlameGraph
  class SVG
    class NoStacksProvided < ArgumentError
      attr_reader :svg
      def initialize svg, msg = "ERROR: No stack counts found"
        @svg = svg
        super msg
      end
    end

    # Data to graph
    attr_accessor :data          # Flamegraph::Data object
    attr_accessor :svg           # SVG string output

    # SVG characteristics
    attr_accessor :width
    attr_accessor :height
    attr_accessor :ypad1         # pad top, include title
    attr_accessor :ypad2         # pad bottom, include labels
    attr_accessor :ypad3         # pad top, include subtitle (optional)
    attr_accessor :framepad      # vertical padding for frames

    # Font Config
    attr_accessor :fonttype
    attr_accessor :fontsize
    attr_accessor :fontwidth
    attr_accessor :fontcolor
    attr_accessor :titlesize     # titlesize
    attr_accessor :subtitlecolor # vdgrey

    # Color Config
    attr_accessor :color         # FlameGraph::Color instance
    attr_accessor :searchcolor

    # Flamegraph Options
    attr_accessor :frameheight
    attr_accessor :inverted
    attr_accessor :nametype

    # Render Options
    attr_accessor :encoding
    attr_accessor :factor
    attr_accessor :negate
    attr_accessor :notes
    attr_accessor :title
    attr_accessor :subtitle
    attr_accessor :countname
    attr_accessor :xpad


    def initialize config = {}
      @data          = config[:data]
      @color         = Color.new config

      @fonttype      = config[:fonttype]
      @fontsize      = config[:fontsize]
      @fontwidth     = config[:fontwidth]
      @fontcolor     = config[:fontcolor]
      @titlesize     = config[:titlesize]
      @subtitlecolor = config[:subtitlecolor]

      @bgcolor1      = config[:bgcolor1]
      @bgcolor2      = config[:bgcolor2]
      @searchcolor   = config[:searchcolor]

      @frameheight   = config[:frameheight]
      @inverted      = config[:inverted]
      @nametype      = config[:nametype]

      @encoding      = config[:encoding].empty? ? nil : config.encoding
      @factor        = config[:factor]
      @negate        = config[:negate]
      @notes         = config[:notes]
      @title         = config[:title]
      @subtitle      = config[:subtitle]
      @countname     = config[:countname]
      @xpad          = config[:xpad]
      @framepad      = config[:framepad]

      @ypad1         = @fontsize * 3
      @ypad2         = @fontsize * 2 + 10
      @ypad3         = @fontsize * 2

      @width         = config[:width]
      @height        = ((data.depthmax + 1) * @frameheight) + @ypad1 + @ypad2
      @height       += @ypad3 unless subtitle.empty?
    end

    def draw!
      return svg if svg

      self.svg = "" # initialize svg string

      validate!

      add_header!
      add_script!
      add_background!
      add_title!
      add_graph_controls!

      draw_frames!

      self.svg << "</svg>\n"
    end

    def header
      info = 'Flame graph stack visualization. '                                   \
             'See https://github.com/brendangregg/FlameGraph for latest version, ' \
             'and http://www.brendangregg.com/flamegraphs.html for examples.'

      enc_attr = @encoding ? %Q{ encoding=\"#{encoding}"} : ""

      <<-SVG.gsub(/^ {8}/, '')
        <?xml version="1.0"#{enc_attr} standalone="no"?>
        <!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
        <svg version="1.1"
             width="#{width}"
             height="#{height}"
             onload="init(evt)"
             viewBox="0 0 #{width} #{height}"
             xmlns="http://www.w3.org/2000/svg"
             xmlns:xlink="http://www.w3.org/1999/xlink">
        <!-- #{info} -->
        <!-- NOTES: #{notes} -->
      SVG
    end

    def definitions
      <<-DEFS.gsub(/^ {8}/, '')
        <defs>
          <linearGradient id="background" y1="0" y2="1" x1="0" x2="0" >
            <stop stop-color="#{color.bgcolor1}" offset="5%" />
            <stop stop-color="#{color.bgcolor2}" offset="95%" />
          </linearGradient>
        </defs>
      DEFS
    end

    def style
      <<-STYLE.gsub(/^ {8}/, '')
        <style type="text/css">
          text              { font-family:#{fonttype}; font-size:#{fontsize}px; fill:#{fontcolor}; }
          #search           { opacity:0.1; cursor:pointer; }
          #search:hover     { opacity:1; }
          #search.show      { opacity:1; }
          #subtitle         { text-anchor:middle; font-color:#{subtitlecolor}; }
          #title            { text-anchor:middle; font-size:#{titlesize}px}
          #unzoom           { cursor:pointer; }
          #frames > *:hover { stroke:black; stroke-width:0.5; cursor:pointer; }
          .hide             { display:none; }
          .parent           { opacity:0.5; }
        </style>
      STYLE
    end

    def script
      locals = [:nametype, :fontsize, :fontwidth, :xpad, :inverted, :searchcolor]

      [
        "<script type=\"text/ecmascript\">",
        "<![CDATA[",
        "#{render 'script.js'}",
        "]]>",
        "</script>",
        ""
      ].join("\n")
    end

    def validate!
      validate_notes
      validate_time
    end

    def error_svg! error_msg = "ERROR: No valid input provided to flamegraph.rb."
      @height = @fontsize * 5

      self.svg = "" # (re)initialize svg string
      add_header!
      self.svg << string_ttf((width / 2).to_i, fontsize * 2, error_msg)
      self.svg << "</svg>\n"
    end

    private

    def add_header!
      self.svg << header
    end

    def add_script!
      self.svg << definitions
      self.svg << style
      self.svg << script
    end

    def add_background!
      self.svg << filled_rectangle(0, 0, width, height, 'url(#background)')
    end

    def add_title!
      self.svg << string_ttf(image_center, fontsize * 2, title, "title")
      self.svg << string_ttf(image_center, fontsize * 4, subtitle, "subtitle") unless subtitle.empty?
    end

    def add_graph_controls!
      self.svg << string_ttf(xpad, height - (ypad2 / 2), " ", "details")
      self.svg << string_ttf(xpad, fontsize * 2, "Reset Zoom", "unzoom", 'class="hide"')
      self.svg << string_ttf(width - xpad - 100, fontsize * 2, "Search", "search")
      self.svg << string_ttf(width - xpad - 100, " ", "matched")
    end

    # Don't try to understand this regexp... because I don't...
    #
    # Basically, by using a `.gsub`, you can convert a non-delimited string
    # into one with commas:
    #
    #   irb> "1234567890".gsub COMMA_ADD_REGEXP, '\1,'
    #   #=> "1,234,567,890"
    #
    # Was added in the original FlameGraph here:
    #
    #     https://github.com/brendangregg/FlameGraph/pull/9
    #
    # with little info, but I think the "perlfaq5" was in reference to this:
    #
    #     https://perldoc.perl.org/perlfaq5.html#How-can-I-output-my-numbers-with-commas-added%3f
    #
    # so for those a little more "adventurous", that gives you a bit of a break
    # down on the regexp being defined.
    #
    COMMA_ADD_REGEXP = /(^[-+]?\d+?(?=(?>(?:\d{3})+)(?!\d))|\G\d{3}(?=\d))/

    def draw_frames!
      self.svg << group_start("id" => "frames")

      data.each do |func, depth, start_time, etime, delta|
        end_time = (func.empty? and depth == 0) ? data.timemax : etime

        ### Building SVG coord on the graph
        x1 = xpad + start_time * data.widthpertime
        x2 = xpad + end_time   * data.widthpertime

        y1, y2 = nil

        if inverted
          y1 = ypad1 + depth * frameheight
          y2 = ypad1 + (depth + 1) * frameheight - framepad
        else
          y1 = height - ypad2 - (depth + 1) * frameheight + framepad
          y2 = height - ypad2 - depth * frameheight
        end

        ### Determining full sample text in graph
        samples       = (end_time - start_time) * factor
        samples_txt   = ("%.0f" % samples).gsub COMMA_ADD_REGEXP, '\1,'
        samples_color = colorize func, delta

        info = nil
        if func.empty? and depth.zero?
          info = "all (#{samples_txt} #{countname}, 100%)"
        else
          pct = "%.2f" % [(100 * samples) / (data.timemax * factor)]

          if delta
            _delta   = negate ? -delta : delta
            deltapct = "%.2f" % [(100 * _delta) / (data.timemax * factor)]
            deltapct = _delta > 0 ? "+#{deltapct}" : deltapct
            info = "#{escape func} (#{samples_txt} #{countname}, #{pct}; #{deltapct}%)"
          else
            info = "#{escape func} (#{samples_txt} #{countname}, #{pct}%)"
          end
        end

        ### Determining sample text for node element, truncate/omit if limited space
        text_space = ((x2 - x1) / (fontsize * fontwidth)).to_i
        node_text  = ""
        node_text  = escape func do |text|
                       text_space < text.length ? "#{text[0, text_space - 2]}.." : text
                     end if text_space >= 3

        ### Draw the element
        name_attrs = data.nameattr[func]
        node_attrs = { "title" => info }.merge name_attrs

        self.svg << (group_start      node_attrs)
        self.svg << (filled_rectangle x1, y1, x2, y2, samples_color, 'rx="2" ry="2"')
        self.svg << (string_ttf       x1 + 3, 3 + (y1 + y2) / 2, node_text)
        self.svg << (group_end)
      end

      self.svg << group_end  # end of 'frames' group
    end

    def escape text
      escaped = "" << text # dup

      escaped.gsub! %r/_\[[kwij]\]$/, '' # strip any annotation

      escaped = yield escaped if block_given?

      # clean up SVG breaking characters:
      escaped.gsub! '&', '&amp;'
      escaped.gsub! '<', '&lt;'
      escaped.gsub! '>', '&gt;'
      escaped.gsub! '"', '&quot;'

      escaped
    end

    def image_center
      @image_center = (width / 2).to_i
    end

    # TODO:  Turn these two into just a "group" function that takes a block?
    def group_start attr = {}
      group        = ""
      group_attrs  = []
      group_attrs << 'id="%s"'    % [attr["id"]]    if attr["id"]
      group_attrs << 'class="%s"' % [attr["class"]] if attr["class"]
      group_attrs << attr["g_extra"]                if attr["g_extra"]

      if attr["href"]
        group_attrs << 'xlink:href="%s"' % [attr["href"]]
        group_attrs << 'target="%s"'     % [attr["target"] || "_top"]
        group       << "<a #{group_attrs.join ' '}>\n"
      else
        group       << "<g #{group_attrs.join ' '}>\n"
      end

      group << "<title>#{attr["title"]}</title>"    if attr["title"]

      group
    end

    def group_end attr = {}
      "</#{attr['href'] ? 'a' : 'g'}>\n"
    end

    def string_ttf x, y, str = " ", id = nil, extra = ""
      x_val  = "%0.2f" % [x]
      id_val = id ? %Q{id="#{id}"} : ""

      %Q{<text #{id_val} x="#{x_val}" y="#{y}" #{extra}>#{str}<\/text>\n}
    end

    RECT_TMPL = %Q{<rect x="%0.1f" y="%s" width="%0.1f" height="%0.1f" fill="%s" %s />\n}
    def filled_rectangle x1, y1, x2, y2, fill, extra = ""
      RECT_TMPL % [x1, y1.to_i, x2 - x1, y2 - y1, fill, extra]
    end

    def colorize func, delta
      if func == "--"
        Color::VDGREY
      elsif func == "-"
        Color::DGREY
      elsif delta
        color.color_scale delta, data.maxdelta
      elsif color.palette?
        color.color_map func
      else
        color.color func
      end
    end

    def render template, locals = []
      template_dir  = File.expand_path "../templates", __FILE__
      template_file = File.join template_dir, "#{template}.erb"
      template_data = File.read template_file

      local_binding = binding.dup.tap do |_binding|
                        locals.each { |var| _binding.local_variable_set var send(var) }
                      end

      ERB.new(template_data, nil, "-").result(local_binding)
    end

    # Make sure we don't have any SVG invalid characters
    def validate_notes
      raise ArgumentError, "Notes string can't contain < or >" if notes =~ /[<>]/
    end

    def validate_time
      raise NoStacksProvided.new(svg) if data.time.zero?
    end
  end
end
